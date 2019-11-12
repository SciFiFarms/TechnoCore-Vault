FROM vault:1.1.1 as base
FROM alpine:3.10
COPY --from=base / /
RUN apk add --no-cache bash mosquitto-clients

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY data/config.hcl /vault/config/config.hcl
COPY data/setup.json /vault/setup/setup.json
COPY policies/ /policies/

# This should be set to where the volume mounts to.
ARG PERSISTANT_DIR=/vault/file
COPY dogfish/ /usr/share/dogfish
COPY migrations/ /usr/share/dogfish/shell-migrations
RUN ln -s /usr/share/dogfish/dogfish /usr/bin/dogfish
RUN mkdir /var/lib/dogfish 
# Need to do this all together because sometimes the config folder is a volume, and anything done in there will be lost. 
# Because of the symlink, the file in the config folder is recreated when dogfish is ran for the first time.
RUN mkdir -p ${PERSISTANT_DIR} && touch ${PERSISTANT_DIR}/migrations.log && ln -s ${PERSISTANT_DIR}/migrations.log /var/lib/dogfish/migrations.log 

## Set up the CMD as well as the pre and post hooks.
COPY go-init /bin/go-init
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY exitpoint.sh /usr/bin/exitpoint.sh
WORKDIR /vault/file

COPY unseal-vault.sh /usr/bin/unseal-vault.sh
ENTRYPOINT ["go-init"]
CMD ["-main", "/usr/bin/entrypoint.sh /docker-entrypoint.sh server", "-post", "/usr/bin/exitpoint.sh"]
