FROM vault
COPY docker-entrypoint.sh usr/local/bin/docker-entrypoint.sh
COPY data/config.hcl /vault/config/config.hcl
COPY * ./
CMD ["server"]
