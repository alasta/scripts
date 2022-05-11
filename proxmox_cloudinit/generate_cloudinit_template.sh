#!/usr/bin/env bash

################################################
#
# Desc : script to generate a cloudinit template
# Creation date : 20220510
# Author : Alasta
# Last modification :
#   - 20220510 : Alasta : initialisation v0.1
#   - 20220511 : Alasta : add CPU, memory option and Cleanning
#
################################################


BIN_BASENAME="/usr/bin/basename"
BIN_CAT="/bin/cat"
BIN_DIRNAME="/usr/bin/dirname"
#Difference between Linux and macos with complet path and builtin
#BIN_ECHO="/bin/echo"
BIN_ECHO="echo"
BIN_PWD="/bin/pwd"

BIN_WGET="/bin/wget"
BIN_QM="/usr/sbin/qm"
BIN_RM="/bin/rm"

VERSION="0.2"

URL_IMG_CLOUDINIT="https://download.rockylinux.org/pub/rocky/8.5/images/Rocky-8-GenericCloud-8.5-20211114.2.x86_64.qcow2"
IMG_CLOUDINIT=$(${BIN_BASENAME} "${URL_IMG_CLOUDINIT}")
IMG_CLOUDINIT_WO_EXTENSION=$(${BIN_BASENAME} "${IMG_CLOUDINIT%.*}")
CLEANNING="FALSE"

CORE_NUMBER="1"
RAM_SIZE="1024"  ##in MB

PROMOX_VM_DISK="local-lvm"

#Stop on first error
set -Eeuo pipefail

#trap signal and execute function
trap f_cleanup SIGINT SIGTERM ERR EXIT

f_cleanning_image_source() {
	${BIN_ECHO} "#=== Cleanning downloaded Cloudinit image (current workdir)"
	${BIN_RM} -f  ${IMG_CLOUDINIT}
}

f_cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  if [ ${CLEANNING} = "TRUE" ]
  then
	f_cleanning_image_source
  fi
}

SCRIPT_DIR=$(cd "$(${BIN_DIRNAME} "${BASH_SOURCE[0]}")" &>/dev/null && ${BIN_PWD} -P)

#Help/Usage
f_usage() {
  ${BIN_CAT} <<EOF
Usage: $(${BIN_BASENAME} "${BASH_SOURCE[0]}") [-h] [-V] [-D] -i <proxmox_id> [-c <core_number>] [-m <memory_size>] [-C]

Script to generate a Cloudinit template.

Available options:

  -h      Print this help and exit
  -V      Print version
  -D      Enable debug
  -i      Proxmox Free ID
  -c	  Number of core
  -m	  RAM size in MBytes
  -C	  Cleanning source image template after operation
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
  while getopts ":hDVi:c:m:C" option
  do
    case $option in
      D) set -x
      ;;
      h) f_usage
         exit 1
      ;;
      V) f_msg "Script version : ${VERSION}"
      ;;
      i) PROXMOX_ID="$OPTARG"
      ;;  
      c) CORE_NUMBER="$OPTARG"
      ;; 
      C) CLEANNING="TRUE"
      ;;	  
	  m) RAM_SIZE="$OPTARG"
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

f_dl_cloudinit_image() {
${BIN_ECHO} "#=== Download Cloudinit image (current workdir)"

if [ -f "$IMG_CLOUDINIT" ]; then
	${BIN_ECHO} "Cloudinit already exists."
else
	${BIN_WGET} -k ${URL_IMG_CLOUDINIT}
fi
}

f_create_local_image() {
${BIN_ECHO} "#=== Generate local image"

#check if PROXMOX_ID is a number and exit is not a number
! [[ ${PROXMOX_ID} =~ ^[0-9]+$ ]] && f_msg "${RED}#> Proxmox ID is not a number - exit${NOFORMAT}" 2

${BIN_QM} create ${PROXMOX_ID} --name "${IMG_CLOUDINIT_WO_EXTENSION//[_.]/-}" ${HW_INFOS}
}

f_importdisk_in_proxmox() {
${BIN_ECHO} "#=== Import image in Proxmox and set HW : ${IMG_CLOUDINIT}"

${BIN_QM} importdisk ${PROXMOX_ID} ${IMG_CLOUDINIT} ${PROMOX_VM_DISK}
${BIN_QM} set ${PROXMOX_ID} --scsihw virtio-scsi-pci --scsi0 ${PROMOX_VM_DISK}:vm-${PROXMOX_ID}-disk-0
${BIN_QM} set ${PROXMOX_ID} --ide2 ${PROMOX_VM_DISK}:cloudinit
${BIN_QM} set ${PROXMOX_ID} --boot c --bootdisk scsi0
${BIN_QM} set ${PROXMOX_ID} --serial0 socket --vga serial0
}

f_custom_user_data() {
${BIN_ECHO} "#=== Set user-data custom"
${BIN_QM} set ${PROXMOX_ID} --cicustom "user=local:snippets/user-data-redhat-like.yaml"
}

f_generate_template() {
${BIN_ECHO} "#=== Convert image to template : id ${PROXMOX_ID}"
${BIN_QM} template ${PROXMOX_ID}
}

##Execution
f_parse_params "$@"
f_setup_colors

###HW set
HW_INFOS=" --memory ${RAM_SIZE} --cores ${CORE_NUMBER} --net0 virtio,bridge=vmbr0"
 

##Download cloudinit image
f_dl_cloudinit_image

##Generate local image
f_create_local_image

##Import image in proxmox + set hw
f_importdisk_in_proxmox

##Set user data custom
f_custom_user_data

##Generate template
f_generate_template
