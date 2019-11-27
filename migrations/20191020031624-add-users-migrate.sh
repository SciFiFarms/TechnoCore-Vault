#!/bin/sh

until vault login "$(cat /run/secrets/token)"; do
    echo "sleeping 5"
    sleep 5
done

# TODO: This should be a generic command: wait_for_mqtt
until mosquitto_pub -i ${MQTT_USER}_test_connection -h mqtt -p 1883 -q 1 \
    -t test/network/up \
    -m "A message" \
    -u $MQTT_USER \
    -P "$(cat /run/secrets/mqtt_password)" \
    2> /dev/null
do
    echo "Couldn't reach MQTT. Will retry in 5 seconds."
    sleep 5
done
sleep 2

for service in $(env | grep CREATE_SERVICE_.*=); do
    echo "Creating policy for service: $service"
    service_name=$(echo "${service}" | cut -d "=" -f 1)
    service=${!service_name}
    echo "Creating policy for service: $service"

    vault policy write $service - < /policies/${service}_policy.hcl # $mqtt 
    local token=$( vault token create -policy=$service -ttl="720h" -display-name="$service" -field="token" )

    create_secret $service vault_token $token
done
