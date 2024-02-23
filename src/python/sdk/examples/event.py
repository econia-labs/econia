import paho.mqtt.client as mqtt
import json

# This is an example on how to use subscribe to events emitted by the DSS.

# Once you have a DSS running (see
# https://econia.dev/off-chain/dss/data-service-stack on how to do that), you
# can run this script by running:
#
# $ poetry install
# $ poetry run event
#
# It will subscribe to all fill events and to place limit order events on
# market 7.
#
# Each MQTT message has a topic and a payload. You can subscribe to topics.
# When specifying the topic you want to subscribe to, you can put a + instead
# of a value to subscribe to all events matching the rest of the topic.
#
# Example:
#
# We use the topic fill/MARKET_ID/USER_ADDRESS/CUSTODIAN_ID. Fill events by the
# user 0xdeadbeef with custodian ID 1 on market 3 will have fill/3/0xdeadbeef/1
# as a topic. But you could subscribe to fill/+/0xdeadbeef/+ to get all fill
# events from the user 0xdeadbeef.

def on_connect(client, userdata, flags, reason_code, properties):
    # Subscribe to all fill events
    client.subscribe("fill/+/+/+")
    # Subscribe to place limit order events on market 7
    client.subscribe("place_limit_order/7/+/+/+")

def on_message(client, userdata, msg):
    # Decode the JSON payload.
    data = json.loads(msg.payload.decode("utf-8"))

    # We subscribed to fills and place_limit_order events.
    # Here, we check which type this one is and we print a message accordingly.
    if msg.topic.startswith("fill"):
        print("New fill event on market " + str(data["market_id"]) + ".")
    else:
        print(str(data["user"]) + " placed a limit order on market 7.")

# Create a new mqtt client
mqttc = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)

# Set the handling functions
mqttc.on_connect = on_connect
mqttc.on_message = on_message

# Connect to the MQTT server (mosquitto)
mqttc.connect("127.0.0.1", 21883, 60)

mqttc.loop_forever()
