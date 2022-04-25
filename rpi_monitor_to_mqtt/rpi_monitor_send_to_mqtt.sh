#!/usr/bin/env bash

################################################
#
# Desc : script to monitor RPI
# Creation date : 2020425
# Author : Alasta
# Last modification :
#
################################################

BIN_BASENAME="/bin/basename"
BIN_CAT="/bin/cat"
BIN_DIRNAME="/bin/dirname"
#Difference between Linux and macos with complet path and builtin
#BIN_ECHO="/bin/echo"
BIN_ECHO="echo"
BIN_PWD="/bin/pwd"
BIN_GREP="/bin/grep"
BIN_HOSTNAME="/bin/hostname"
BIN_DATE="/bin/date"
BIN_AWK="/bin/awk"
BIN_JO="/usr/bin/jo"
BIN_VCGENCMD="/bin/vcgencmd"
BIN_DF="/bin/df"
BIN_FREE="/bin/free"
BIN_SLEEP="/bin/sleep"
BIN_MOSQUITTO_PUB="/bin/mosquitto_pub"
BIN_SED="/bin/sed"

VERSION="0.1"

C_MQTT_SERVER="192.168.0.1"
C_MQTT_PORT="1883"
C_MQTT_TOPIC="iot/resources/${HOSTNAME}"
C_MQTT_USER="user_mqtt"
C_MQTT_PWD='password_mqtt'

#Stop on first error
set -Eeuo pipefail

#trap signal and execute function
trap f_cleanup SIGINT SIGTERM ERR EXIT

f_cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

SCRIPT_DIR=$(cd "$(${BIN_DIRNAME} "${BASH_SOURCE[0]}")" &>/dev/null && ${BIN_PWD} -P)

#Help/Usage
f_usage() {
  ${BIN_CAT} <<EOF
Usage: $(${BIN_BASENAME} "${BASH_SOURCE[0]}") [-h] [-V] [-D]

Description : monitoring RPI : %CPU %Memory CPU Temperature Alimentation Model %/ %/boot load average

Available options:

  -h      Print this help and exit
  -V      Print version
  -D      Enable debug
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
      V) f_msg "Script version : ${VERSION}"
      ;;
      \?) f_die "*** Error ***" 2
      ;;
      :) f_die "*** Option \"$OPTARG\" not set ***" 3
      ;;
      *) f_die "*** Option \"$OPTARG\" unknown ***" 4
      ;;
    esac
  done
}

##Execution
f_parse_params "$@"
f_setup_colors

f_date(){
	${BIN_DATE} '+%s'
}

f_cpu_temperature(){
	${BIN_CAT} /sys/class/thermal/thermal_zone0/temp
}

f_hostname(){
	${BIN_HOSTNAME}  
}

f_model_rpi(){
	${BIN_GREP} Model /proc/cpuinfo | ${BIN_AWK} -F": " '{print $2}' | ${BIN_SED} -e 's/ /_/g'
}

f_alim_throttled(){
	${BIN_VCGENCMD} get_throttled | ${BIN_AWK} -F"=" '{print $2}'
}

f_percent_disk_use_root(){
	${BIN_DF} / | ${BIN_GREP} -v Filesystem | ${BIN_AWK} '{split($(NF-1),tab,"%");print tab[1]}'
}

f_percent_disk_use_boot(){
	${BIN_DF} /boot | ${BIN_GREP} -v Filesystem  | ${BIN_AWK} '{split($(NF-1),tab,"%");print tab[1]}' 
}

f_load_avg(){
	${BIN_CAT} /proc/loadavg
}
C_LOAD_AVG=$(f_load_avg)

f_percent_memory_use(){
	${BIN_FREE} | ${BIN_GREP} Mem | ${BIN_AWK} '{printf "%.1f\n", $3/$2 * 100.0}' 
}

f_percent_cpu_use(){
	${BIN_AWK} '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else printf  "%.1f\n", ($2+$4-u1) * 100 / (t-t1); }' <(${BIN_GREP} 'cpu ' /proc/stat) <(${BIN_SLEEP} 0.5;${BIN_GREP} 'cpu ' /proc/stat)                      
}

f_generate_json_monitor(){
	${BIN_JO} timestamp=$(f_date) cpu_temp_celsius=$(f_cpu_temperature) hostname=$(f_hostname) model=$(f_model_rpi) alim_throttled="$(f_alim_throttled)" percent_disk_use_root=$(f_percent_disk_use_root) percent_disk_use_boot=$(f_percent_disk_use_boot) load_avg[load_avg_1min]=$(echo ${C_LOAD_AVG} | ${BIN_AWK} '{print $1}') load_avg[load_avg_5min]=$(echo ${C_LOAD_AVG} | ${BIN_AWK} '{print $2}') load_avg[load_avg_15min]=$(echo ${C_LOAD_AVG} | ${BIN_AWK} '{print $3}') percent_mem_usage=$(f_percent_memory_use) percent_cpu_usage=$(f_percent_cpu_use)
}

f_push_mqtt(){
	${BIN_MOSQUITTO_PUB} -h ${C_MQTT_SERVER} -p ${C_MQTT_PORT}  -t ${C_MQTT_TOPIC} -m ${C_MQTT_MESSAGE} -u ${C_MQTT_USER} -P ${C_MQTT_PWD}
}

C_MQTT_MESSAGE=$(f_generate_json_monitor)

f_push_mqtt
