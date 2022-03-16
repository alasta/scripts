#!/usr/bin/env bash

################################################
#
# Desc : Script to backup my personal files, .rpm and .log files are exclude
# Creation date : 2020316
# Author : Alasta
# Last modification :
#   - 20220316 : Alasta : init
#
################################################



BIN_BASENAME="/usr/bin/basename"
BIN_CAT="/bin/cat"
BIN_DATE="/bin/date"
BIN_DIRNAME="/usr/bin/dirname"
#Difference between Linux and macos with complet path and builtin
#BIN_ECHO="/bin/echo"
BIN_ECHO="echo"
BIN_HOSTNAME="/bin/hostname"
BIN_PWD="/bin/pwd"
BIN_TAR="/bin/tar" #Linux
#BIN_TAR="/usr/bin/tar" #MacOS



SCRIPT_DIR=$(cd "$(${BIN_DIRNAME} "${BASH_SOURCE[0]}")" &>/dev/null && ${BIN_PWD} -P)

#init variables
VERSION="0.1"
C_EXECUTE=""

FILE_LIST_TO_BCK="${SCRIPT_DIR}/ressources_to_backup"

FILE_LIST_TAR=""
FILENAME_BCK="bck_personal_config_"$(${BIN_HOSTNAME})"_"$(${BIN_DATE} "+%Y%m%d_%s.tgz")
EXCLUDE_TAR="--exclude=*.rpm --exclude=*.log"

#Target where store the backup
REMOTE_FOLDER_BCK="/tmp/"


#Stop on first error
set -Eeuo pipefail

#trap signal and execute function
trap f_cleanup SIGINT SIGTERM ERR EXIT

f_cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}





#Help/Usage
f_usage() {
  ${BIN_CAT} <<EOF
Usage: $(${BIN_BASENAME} "${BASH_SOURCE[0]}") [-h] [-V] [-D] -e

Backup personal files.

Available options:

  -h      Print this help and exit
  -V      Print version
  -D      Enable debug
  -e      Execute backup
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

f_generate_list_files(){
  f_msg "Generate files list to backup :"

  [[ ! -e ${FILE_LIST_TO_BCK} ]] && f_die "${RED}File with the files list to backup not exit !${NOFORMAT}\n Please create ${FILE_LIST_TO_BCK}" 2


  for i in $(${BIN_CAT} ${FILE_LIST_TO_BCK})
  do
    #constitution de la liste des fichiers a donner a tar
    FILE_LIST_TAR="${FILE_LIST_TAR} ${i}"
  done
  f_msg "${GREEN}OK${NOFORMAT}"
}


f_backup(){
  f_generate_list_files
  f_msg "Generate backup :  "
  ${BIN_TAR} czf  "${REMOTE_FOLDER_BCK}${FILENAME_BCK}"  ${FILE_LIST_TAR}  ${EXCLUDE_TAR}
  [[ ! $? -eq 0 ]] && f_die "${RED}Error in backup execution !${NOFORMAT}" 3
  f_msg "${GREEN}OK${NOFORMAT}"

}


f_parse_params() {
  while getopts ":hDVe" option
  do
    case $option in
      D) set -x
      ;;
      h) f_usage
         exit 1
      ;;
      V) f_msg "Script version : ${VERSION}"
        exit 5
      ;;
      e) C_EXECUTE="1"
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

if [[ ${C_EXECUTE} -eq 1 ]]
then
  f_backup
else
  f_usage
fi
