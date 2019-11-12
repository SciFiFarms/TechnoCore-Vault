#!/usr/bin/env bash

until vault operator unseal $(cat /run/secrets/unseal) ; do
    echo "Waiting for vault to come up before unsealing. Sleeping 3."
    sleep 3
done
