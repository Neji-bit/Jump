#!/bin/sh

# Tempfile & cleanup trap.
trap 'cleanup' 0 1 2 3 15
cleanup () {
  echo "CLEANUP!"
  [[ -n ${tmpfile-} ]] && rm -f "$tmpfile"
  return 0
}
tmpfile=$(mktemp "/tmp/${0##*/}.tmp.XXXXXX")

TEST_NUM=0
SUCCEED=0
FAILED=0
PASSED=0
PWD=

MSG=
PASSED_FLG=

function do_test() {
  local TEST_NAME=$1
  MSG=
  PASSED_FLG=
  TEST_NUM=`expr $TEST_NUM + 1`
  printf '#### CASE %02d : %s ####\n' $TEST_NUM $TEST_NAME
  $TEST_NAME > /dev/null 2>&1
  local RESULT=$?
  if [ -n "$PASSED_FLG" ]; then
    echo "PASSED."
    PASSED=`expr $PASSED + 1`
    [[ -n "$MSG" ]] && echo "$MSG"
    echo ""
    return
  fi
  if [ 0 -eq ${RESULT} ]; then
    echo "SUCCEED."
    SUCCEED=`expr $SUCCEED + 1`
  else
    echo "FAILED."
    FAILED=`expr $FAILED + 1`
  fi
  [[ -n "$MSG" ]] && echo "$MSG"
  echo ""
}

function result() {
  cat << EOF
#### RESULT ####
SUCCESS : `printf '%02d' $SUCCEED`
FAILED  : `printf '%02d' $FAILED`
PASSED  : `printf '%02d' $PASSED`
TOTAL   : `printf '%02d' $TEST_NUM`
EOF
}

# prepare check.
function prepare() {
  if [ -e "/bin/jump.sh" -a -e "/etc/profile.d/jump_init.sh" ]; then
    return 0
  fi
  return 1
}

# Initialize.
function initialize() {
  . /etc/profile.d/jump_init.sh
  mv $JUMP_FILE ./org_jumpfile
  PWD=`pwd`
}

# Finalize
function finalize() {
  mv ./org_jumpfile $JUMP_FILE 
}

# version.
function version() {
  jump -v 2>&1 | grep "Version" > /dev/null 2>&1
  return $?
}

# usage.
function usage() {
  jump -u 2>&1 | grep "Usage" > /dev/null 2>&1
  return $?
}

# No bookmarkfile Error.
function no_file_error() {
  jump 2>&1 | grep "Error" > /dev/null 2>&1
  return $?
}

# Add a new item.
function add() {
  jump -a FIRST
  result=$?
  if [ 0 == $result ]; then
    grep "^FIRST" $JUMP_FILE > /dev/null 2>&1
    result=$?
  fi
  return $result
}

function add_with_path() {
  jump -a SECOND /tmp
  result=$?
  if [ 0 == $result ]; then
    grep "^SECOND /tmp" $JUMP_FILE > /dev/null 2>&1
    result=$?
  fi
  return $result
}

function add_with_comment() {
  jump -a THIRD /etc path of the etc.
  result=$?
  if [ 0 == $result ]; then
    grep "^THIRD /etc \+# path of the etc." $JUMP_FILE > /dev/null 2>&1
    result=$?
  fi
  return $result
}

# list.
function list() {
  jump -l > $tmpfile
  diff $tmpfile ./LIST_SUCCEED > /dev/null 2>&1
  return  $?
}

# jump to.
function jump_to() {
  jump THIRD
  MSG="pwd : `pwd`"
  [[ "`pwd`" == "/etc" ]]
  return $?
}

# back to.
function back_to() {
  jump -b
  MSG="pwd : `pwd`"
  [[ "`pwd`" == "$PWD" ]]
  return $?
}

# modified.
function modified() {
  MSG='* There is no way to do it. *'
  PASSED_FLG=true
  return 0
}

# path.
function path() {
  local path=`jump -p THI`
  [[ "$path" == "/etc" ]]
  return $?
}

#
# Do the Test.
#

prepare
[[ 0 -ne $? ]] && echo "Error. Jump is not installed on this machine." >&2 && exit 1
initialize

do_test version
do_test usage
do_test no_file_error
do_test add
do_test add_with_path
do_test add_with_comment
do_test list
do_test jump_to
do_test back_to
do_test modified
do_test path

result
finalize

exit 0

