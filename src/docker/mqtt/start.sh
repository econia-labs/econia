#!/bin/bash

echo "mqtt_publisher:$MQTT_PASSWORD" > /password_file

chmod 600 /password_file

mosquitto_passwd -U /password_file

chown mosquitto:mosquitto /password_file

/usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf &

sleep 5

/app/mqtt-publisher &

wait -n

exit $?
