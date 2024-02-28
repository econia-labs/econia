#!/bin/sh

echo "mqtt_publisher:$MQTT_PASSWORD" > /password_file

chmod 600 /password_file

mosquitto_passwd -U /password_file

cat /password_file

chown mosquitto:mosquitto /password_file

/usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf
