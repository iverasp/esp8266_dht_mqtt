require "auth"

MQTT_ADDRESS = "192.168.1.42"
MQTT_PORT = 8883

MQTT_KEEPALIVE = 120
MQTT_TOPIC_TEMPERATURE = "/temperature"
MQTT_TOPIC_HUMIDITY = "/humidity"

READING_DELAY_MS = 60000
DHT_PIN = 4

client = mqtt.Client(MQTT_ID, MQTT_KEEPALIVE, MQTT_USERNAME, MQTT_PASSWORD)
temperature = 0
humidity = 0

wifi.setmode(wifi.STATION)
wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)
wifi.sta.connect()

function get_and_publish_sensor_data()
    status, temperature, humidity, temp_dec, hum_dec = dht.read(DHT_PIN)
    if status == dht.OK then
        publish_sensor_data()
    else
        print("DHT reading unsuccessful")
    end
end

function publish_sensor_data()
    client:publish(MQTT_TOPIC_TEMPERATURE, temperature, 0, 0,
        function(client)
            print("Sent temperature ".. temperature)
            client:publish(MQTT_TOPIC_HUMIDITY, humidity, 0, 0,
                function(client)
                    print("Sent humidity ".. humidity)
                    client:close()
                end)
        end)
end

function loop()
    if wifi.sta.status() == wifi.STA_GOTIP then
        client:connect(MQTT_ADDRESS, MQTT_PORT, 0, function(connection)
            get_and_publish_sensor_data()
        end)
    else
        print("Connecting...")
    end
end

tmr.alarm(0, READING_DELAY_MS, tmr.ALARM_AUTO, function()
    loop()
end)
