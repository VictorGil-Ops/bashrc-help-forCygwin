#!/bin/bash

function prompt {
  local BLUE="\[\033[0;34m\]"
  local DARK_BLUE="\[\033[1;34m\]"
  local RED="\[\033[0;31m\]"
  local DARK_RED="\[\033[1;31m\]"
  local YELLOW="\[\033[1;33m\]"
  local NO_COLOR="\[\033[0m\]"
  case $TERM in
    xterm*|rxvt*)
      TITLEBAR='\[\033]0;\w@\h:\w\007\]'
	  CLUSTER='\[$(oc config current-context)]'
      ;;
    *)
      TITLEBAR=""
      ;;
  esac
  PS1="\u@\d [\t]> "
  PS1="${TITLEBAR}\
  $BLUE\u@\d $RED[\t] $YELLOW[${CLUSTER}]\n>$NO_COLOR"
  PS2='continue-> '
  PS4='$0.$LINENO+ '
}

prompt
