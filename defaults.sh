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

if ! docker volume ls | grep -w "${STACK_NAME}_vault" 1>&2 ; then
    export SERVICE_CONFIG_VAULT_INIT=${TECHNOCORE_SERVICES}/vault/init.yml
fi

set_optional_service vernemq

generate_mount dev migrations /usr/share/dogfish/shell-migrations
