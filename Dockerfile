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
# create a non-root user
# add the user to the docker group
RUN addgroup -S docker && \
    adduser -D rdocker && \
    addgroup rdocker docker

# copy files
WORKDIR /
COPY  --chown=rdocker:rdocker \
    lib/config.inc.sh lib/env.inc.sh lib/util.inc.sh \
    /rdocker/lib/
COPY  --chown=rdocker:rdocker \
    bin/rdocker /rdocker/bin/
COPY --chown=rdocker:rdocker \
    ./docker/entrypoint.sh /entrypoint.sh

# set permissions
RUN chmod +x /rdocker/bin/rdocker && \
    chmod +x /entrypoint.sh && \
    ln -s /rdocker/bin/rdocker /usr/local/bin/rdocker

WORKDIR /rdocker
USER rdocker
ENTRYPOINT ["/entrypoint.sh"]
CMD ["rdocker", "tunnel-up"]

EXPOSE 12345
