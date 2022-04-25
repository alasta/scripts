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
- C_MQTT_TOPIC="iot/resources/${HOSTNAME}"
- C_MQTT_USER="user_mqtt"
- C_MQTT_PWD='password_mqtt'
  
  
## Scheduling

Edit crontab :
```
\# Monitoring RPI to MQTT server
*/5     *       *       *       *       /path/to/script/rpi_monitor_send_to_mqtt.sh
```

## Bonus

To get this informations in Home Assistant, add the following sensors in your configuration :  
```
##MQTT resources IoT RPI wmbusmeters
- platform: mqtt
  name: "resource rpi wmbusmeters alim problem"
  state_topic: "<C_MQTT_TOPIC>"
  value_template: "{{ value_json['alim_throttled']}}"
  icon: mdi:power-plug

- platform: mqtt
  name: "resource rpi wmbusmeters percent disk use root"
  state_topic: "<C_MQTT_TOPIC>"
  unit_of_measurement: "%"
  state_class: measurement
  value_template: "{{ value_json['percent_disk_use_root']}}"
  icon: mdi:harddisk

- platform: mqtt
  name: "resource rpi wmbusmeters percent disk use boot"
  state_topic: "<C_MQTT_TOPIC>"
  unit_of_measurement: "%"
  state_class: measurement
  value_template: "{{ value_json['percent_disk_use_boot']}}"
  icon: mdi:harddisk

- platform: mqtt
  name: "resource rpi wmbusmeters percent memory usage"
  state_topic: "<C_MQTT_TOPIC>"
  unit_of_measurement: "%"
  state_class: measurement
  value_template: "{{ value_json['percent_mem_usage']}}"
  icon: mdi:memory

- platform: mqtt
  name: "resource rpi wmbusmeters percent cpu usage"
  state_topic: "<C_MQTT_TOPIC>"
  unit_of_measurement: "%"
  state_class: measurement
  value_template: "{{ value_json['percent_cpu_usage']}}"
  icon: mdi:cpu-32-bit

- platform: mqtt
  name: "resource rpi wmbusmeters cpu temperature"
  state_topic: "<C_MQTT_TOPIC>"
  unit_of_measurement: "C"
  state_class: measurement
  device_class: temperature
  value_template: "{{ (value_json['cpu_temp_celsius']|float * 0.001)|round(2)}}"
  icon: mdi:thermometer

- platform: mqtt
  name: "resource rpi wmbusmeters load average 5 min"
  state_topic: "<C_MQTT_TOPIC>"
  value_template: "{{ value_json.load_avg.load_avg_5min}}"
  icon: mdi:thermometer
```
  
Note :   
Modify "<C_MQTT_TOPIC>" by your MQTT topic.



