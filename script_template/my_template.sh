#!/usr/bin/env bash

################################################
#
# Desc : script to ....
# Creation date : 2020316
# Author : Alasta
# Last modification :
#   - 20220316 : Alasta : Update ....
#
################################################



BIN_BASENAME="/usr/bin/basename"
BIN_CAT="/bin/cat"
BIN_CD="/usr/bin/cd"
BIN_DIRNAME="/usr/bin/dirname"
#Difference between Linux and macos with complet path and builtin
#BIN_ECHO="/bin/echo"
BIN_ECHO="echo"
BIN_PWD="/bin/pwd"

VERSION="0.1"


#Stop on first error
set -Eeuo pipefail

#trap signal and execute function
trap f_cleanup SIGINT SIGTERM ERR EXIT

f_cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}



SCRIPT_DIR=$(${BIN_CD} "$(${BIN_DIRNAME} "${BASH_SOURCE[0]}")" &>/dev/null && ${BIN_PWD} -P)

#Help/Usage
f_usage() {
  ${BIN_CAT} <<EOF
Usage: $(${BIN_BASENAME} "${BASH_SOURCE[0]}") [-h] [-V] [-D] -p <param_value> 

Script description here.

Available options:

  -h      Print this help and exit
  -V      Print version
  -D      Enable debug
  -p      Set parameter
EOF
  exit
}
#Color setup
#Disable color with export env variable before launch script
#export NO_COLOR=1
f_setup_colors() {
  if [[ -t 2 ]] && [[  "${NO_COLOR:=0}" -eq 0  ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}





#Script message
f_msg() {
  "${BIN_ECHO}" >&2 -e "${1-}"
    #echo  >&2 -e "${1-}"

}

#bad output
f_die() {
  local MSG=$1
  local CODE=${2-1} # default exit status 1
  f_msg "${MSG}"
  exit "${CODE}"
}



f_parse_params() {
  while getopts ":hDVp:" option
  do
    case $option in
      D) set -x
      ;;
      h) f_usage
         exit 1
      ;;
      V) f_msg ${VERSION}
      ;;
      p) MY_PARAM_VALUE="$OPTARG"
      ;;  
      \?) f_die "*** Error ***" 2
      ;;
      :) f_die "*** Option \"$OPTARG\" not set ***" 3
      ;;
      *) f_die "*** Option \"$OPTARG\" unknown ***" 4
      ;;
    esac
  done

  args=("$@")
  [[ ${#args[@]} -eq 0 ]] && f_die "Missing script arguments"
  return 0
}

##Execution
f_parse_params "$@"
f_setup_colors


f_msg "${RED}This is${NOFORMAT} demo"
f_msg "${GREEN}This is${NOFORMAT} demo"
f_msg "${ORANGE}This is${NOFORMAT} demo"
f_msg "${BLUE}This is${NOFORMAT} demo"
f_msg "${PURPLE}This is${NOFORMAT} demo"
f_msg "${CYAN}This is${NOFORMAT} demo"
f_msg "${YELLOW}This is${NOFORMAT} demo"
