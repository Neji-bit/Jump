export JUMP_FILE=~/.jump
export JUMP_EDITOR=vim
export JUMP_BACK=

function jump () {
  jump.sh $*
  local result=$?
  if [ 0 == $result ]; then
    [[ -s ~/.jump_backpath ]] && export JUMP_BACK=`cat ~/.jump_backpath`
    [[ -s ~/.jump_cdpath ]] && eval "cd `cat ~/.jump_cdpath`"
    [[ -s ~/.jump_modified ]] && ${JUMP_EDITOR} ${JUMP_FILE}
  fi
  return $result
}

alias j="jump"
alias jm="jump -m"  # Modify jumpfile.
alias jb="jump -b"  # Jump to the Back.
alias jp="jump -p"  # Show the path instead of change directory.

