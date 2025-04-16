FROM alpine:3.21.3

# Install dependencies
RUN apk add --no-cache \
    docker-cli \
    openssh-client \
    autossh \
    openssl \
    bash \
    curl \
    jq \
    socat \
    byobu \
    expect \
    && rm -rf /var/cache/apk/*

# create group docker
# create a non-root user "rocker" with home directory /rdocker
# and add the user to the docker group
RUN addgroup -S docker && \
    adduser -D rdocker -h /rdocker && \
    addgroup rdocker docker

# copy files
WORKDIR /
COPY  --chown=rdocker:rdocker \
    lib/config.inc.sh lib/env.inc.sh lib/util.inc.sh \
    /rdocker/lib/
COPY  --chown=rdocker:rdocker \
    bin/rdocker /rdocker/bin/
COPY --chown=rdocker:rdocker \
    ./docker/entrypoint.sh ./docker/healthcheck.sh /


# set permissions
RUN chmod +x /rdocker/bin/rdocker && \
    chmod +x /entrypoint.sh && \
    chmod +x /healthcheck.sh && \
    ln -s /rdocker/bin/rdocker /usr/local/bin/rdocker && \
    ln -s /healthcheck.sh /usr/local/bin/healthcheck && \
    ln -s /entrypoint.sh /usr/local/bin/entrypoint

# healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD /usr/local/bin/healthcheck

# entrypoint
WORKDIR /rdocker
ENTRYPOINT ["/entrypoint.sh"]
CMD ["rdocker", "tunnel-up"]
USER rdocker

# networking
EXPOSE 12345
