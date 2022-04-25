# RPI monitoring

## Description :

Send monitoring informations to MQTT server :  
- Timestamp
- CPU temperature
- Hostname
- Model
- Alimentation throttled
- Disk use percent /
- Disk use percent /boot
- Load average 1min/5min/15min
- CPU use percent
- Memory use percent
  
  
## Configuration :

Modify the following variables :  
- C_MQTT_SERVER="192.168.0.1"
- C_MQTT_PORT="1883"
- C_MQTT_USER="user_mqtt"
- C_MQTT_PWD='password_mqtt'
  
  
## Scheduling

Edit crontab :
```
\# Monitoring RPI to MQTT server
*/5     *       *       *       *       /path/to/script/rpi_monitor_send_to_mqtt.sh
```
