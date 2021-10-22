#!/bin/bash

VERSION="0.00.02"

set -e
MUTE=true

# Tempfile & cleanup trap.
trap 'cleanup && log "Exit." 1>&2' 0
trap 'log "Catch a Signal" 1>&2' 1 2 3 15
cleanup () {
  [[ -n ${tmpfile_l-} ]] && rm -f "$tmpfile_l"
  [[ -n ${tmpfile_r-} ]] && rm -f "$tmpfile_r"
  log "cleanup" 1>&2
  return 0
}
tmpfile_l=$(mktemp "/tmp/${0##*/}.tmp.XXXXXX")
tmpfile_r=$(mktemp "/tmp/${0##*/}.tmp.XXXXXX")

# For maintenance. This log function references MUTE environment.
log () {
  [[ -z "$MUTE" ]] && echo $@
  return 0
}

# Long-option support.
# Before the getopts process, overwrite long-options with short-options.
long2short() {
  local OPT
  for OPT in $@; do
    case $OPT in
      --version  )  echo  "-v"  &&  continue;;
      --usage    )  echo  "-u"  &&  continue;;
      --list     )  echo  "-l"  &&  continue;;
      --back     )  echo  "-b"  &&  continue;;
      --add      )  echo  "-a"  &&  continue;;
      --modified )  echo  "-m"  &&  continue;;
      --path     )  echo  "-p"  &&  continue;;
      *          )  echo $OPT
    esac
  done
  return 0
}
REGULAR_ARGS=(`long2short $@`)

# Process args.
opts() {
  local OPT
  while getopts vulbamp OPT; do
    case "$OPT" in
      v ) FLAG_V=true;;
      u ) FLAG_U=true;;
      l ) FLAG_L=true;;
      b ) FLAG_B=true;;
      a ) FLAG_A=true;;
      m ) FLAG_M=true;;
      p ) FLAG_P=true;;
      * ) usage && exit 1;;
    esac
  done
  return 0
}
opts ${REGULAR_ARGS[@]}
shift $((OPTIND - 1))   # Discard options from buffer.

# Functions. These functions are paired with options.

# --version
version() {
  echo "Version: ${VERSION}" 1>&2
  return 0
}

# --usage
usage() {
  cat << EOT 1>&2
  Usage:
    jump [-v] [-u]
    jump dir-shortcut-name
    jump [-l]
    jump [-b]
    jump [-a] NICKNAME [PATH]
    jump [-m]

  Description:

    Jump to the registered directories quickly.
    Notice: This script requires support for bash functions.

  Initialize:

    First, you make the ~/.jump file.
    This file's format is as follows:
      <NAME> <PATH>

    Ex:
      HOME ~/
      FAVORITE ~/workspace/current/
      LOGDIR ~/workspace/logs/

  Options:

    -v, --version   Version
    -u, --usage     Usage
    -l, --list      List shortcuts.
    -b, --back      Back to the previous directory.
    -a, --add       Add a shortcut ( a set of NICKNAME and PATH ).
    -m, --modified  Modified the List of shortcuts on your editor.
    -p, --path      Show the path instead of change directory.

  Notice:
    If you want to check the aliases of this command, 
    please see the '/etc/profile.d/jump_init.sh' file.

EOT
  return 0
}

# --list
list() {
  local _BOOKMARK_FILE=$1
  cat ${_BOOKMARK_FILE}
  return $?
}

# --back
back() {
  if [ -n "$JUMP_BACK" ]; then  # "JUMP_BACK" is a ENV.
    pwd > $BACKPATH_WORKFILE
    echo -n "$JUMP_BACK" > $CDPATH_WORKFILE
  fi
  return 0
}

# --add
add() {
  local _NICKNAME=$1 && [[ -n "${_NICKNAME}" ]] && shift
  local _NEWPATH=$1 && [[ -n "${_NEWPATH}" ]] && shift
  local _COMMENT="$*"
  local _LINE=
  [[ -z "${_NEWPATH}" ]] && _NEWPATH=`pwd`
  [[ -z "${_NICKNAME}" || -z "${_NEWPATH}" ]] && echo "Error: Add requires a double param of nickname and path." 1>&2 && return 1
  _LINE="${_NICKNAME} `_absolute_path ${_NEWPATH}`"
  [[ -n "$_COMMENT" ]] && _LINE="${_LINE} # $_COMMENT"
  echo "${_LINE}" >> ${BOOKMARK_FILE}
  _auto_format
  return 0
}

# --modified
modified() {
  echo "true" >> ${MODIFIED_WORKFILE}
  return 0
}

# jump to (= no option).
jump() {
  local _BOOKMARK_FILE=$1
  local _JUMP_TO=$2
  local _TO_PATH=`_trim ${BOOKMARK_FILE} | grep "^${_JUMP_TO}" | cut -d\  -f 2`
  [[ -z "$_TO_PATH" ]] && exit 1
  [[ 1 -ne `echo "${_TO_PATH}" | wc -w` ]] && grep "^${_JUMP_TO}" ${_BOOKMARK_FILE} && exit 1
  if [ -n "${FLAG_P}" ]; then
    echo "$_TO_PATH"
  else
    pwd > $BACKPATH_WORKFILE
    echo -n "$_TO_PATH" > $CDPATH_WORKFILE
  fi
  return 0
}

# The following are local functions.

_auto_format() {
  # T.B.D.
  return 0
}

_exist_listfile() {
  local _BOOKMARK_FILE=$1
  if [ -r "${_BOOKMARK_FILE}" ]; then
    return 0
  else
    echo "Error: The file ${JUMP_FILE} was not exist." 1>&2
    return 1
  fi
}

_trim() {
  local _BOOKMARK_FILE=$1
  sed -e "s/[[:space:]]\+/ /g" -e "s/^[[:space:]]*//g" -e "s/[[:space:]]*$//g" $_BOOKMARK_FILE
}

_absolute_path() {
  readlink -f $1
}

#
# Main proc.
#

BOOKMARK_FILE=${JUMP_FILE}  # "JUMP_FILE" is a ENV.
[[ -z "$BOOKMARK_FILE" ]] && BOOKMARK_FILE=~/.jump

BACKPATH_WORKFILE=~/.jump_backpath
CDPATH_WORKFILE=~/.jump_cdpath
MODIFIED_WORKFILE=~/.jump_modified
echo -n "" > ${BACKPATH_WORKFILE}
echo -n "" > ${CDPATH_WORKFILE}
echo -n "" > ${MODIFIED_WORKFILE}

if [ -n "$FLAG_V" ]; then version;   exit $?; fi
if [ -n "$FLAG_U" ]; then usage;     exit $?; fi
if [ -n "$FLAG_M" ]; then modified;  exit $?; fi
if [ -n "$FLAG_A" ]; then add $*;    exit $?; fi
if [ -n "$FLAG_B" ]; then back;      exit $?; fi

_exist_listfile ${BOOKMARK_FILE} || exit $?
if [ -n "$FLAG_L" ]; then list ${BOOKMARK_FILE}; exit $?; fi
JUMP_TO=$1 && [[ -n "$JUMP_TO" ]] && shift
if [ -n "$JUMP_TO" ]; then jump ${BOOKMARK_FILE} ${JUMP_TO}; exit $?; fi

list ${BOOKMARK_FILE}

exit 0

