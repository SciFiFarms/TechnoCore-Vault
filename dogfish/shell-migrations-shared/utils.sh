#!/bin/bash

reboot_function()
{
    kill -s SIGTERM 1
}

# $1: The field to extract. 
# $2: The JSON string.
extract_from_json(){
    grep -Eo '"'$1'":.*?[^\\]"' <<< "$2" | cut -d \" -f 4
}

# $1: The service this secret is for
# $2: Mount point for the secret. mqtt_username is an example. 
# $3: The secret to store. 
# This used to be of the format service_name/mount_point
function create_secret()
{
    echo "dogfish: Creating secrect $1_$2"
    until mosquitto_pub -i ${MQTT_USER}_dogfish_create_secret -h mqtt -p 1883 -q 2 \
        -t portainer/secret/create/$1/$2 \
        -m "$3" \
        -u $MQTT_USER \
        -P "$(cat /run/secrets/mqtt_password)"
    do
        echo "Couldn't connect to MQTT. Sleeping."
        sleep 5
    done
        
    #echo "Finished create_secret()"
}

# $1: The number of random characters to generate.
function get_random()
{
    local response
    # TODO: I think there is a programatic way to do this that would allow for 
    # max retries annd sleep time to be passed in as parameters. 
    until response=$(http --check-status --verify=/run/secrets/ca \
        POST https://vault:8200/v1/sys/tools/random/$1 \
        X-Vault-Token:$(cat /run/secrets/token))
    do
        echo "Can't reach Vault, sleeping." >&2
        sleep 1
    done;
    echo $response
}