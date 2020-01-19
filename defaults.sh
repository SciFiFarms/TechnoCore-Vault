#!/bin/env bash

#TODO: Anything that gets sent to STDOUT from this file gets included in the 
#      final compose file, which usually breaks it. 

# compose.sh defaults $service_name to the service's directory name. It can be overridden here. 
# service_name=

# Leave blank to disable this service by default.
set_service_flag $service_name
#set_service_flag $service_name yes

# Sets the application prefix depending on what $INGRESS_TYPE is set to. 
# Results in one of the following paths: 
# https://some.domain/prefix/
# https://prefix.some.domain/
# prefix=$service_name

if [ "$SERVICE_VAULT" ] && ! docker volume ls | grep -w "${STACK_NAME}_vault" > /dev/null ; then
    export SERVICE_CONFIG_VAULT_INIT=${TECHNOCORE_SERVICES}/vault/init.yml
fi

set_optional_service vernemq

# TODO: I don't actually expect this to work. Need to implement the "file" mount type.
#generate_mount file data/config.hcl /vault/config/config.hcl
generate_mount dev migrations /usr/share/dogfish/shell-migrations
