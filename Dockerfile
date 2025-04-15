FROM alpine:3.21

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
    byobu && \
    rm -rf /var/cache/apk/*

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
RUN mkdir -p /rdocker/run && \
    chown rdocker:rdocker /rdocker/run && \
    mkdir -p /.rdocker && \
    chown rdocker:rdocker /.rdocker && \
    chmod +x /rdocker/bin/rdocker && \
    chmod +x /entrypoint.sh && \
    ln -s /rdocker/bin/rdocker /usr/local/bin/rdocker

WORKDIR /rdocker
USER rdocker
ENTRYPOINT ["/entrypoint.sh"]
CMD ["rdocker", "tunnel-up"]

EXPOSE 12345
