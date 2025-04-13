FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    docker-cli \
    openssh-client \
    autossh \
    openssl \
    bash


# create a non-root user
RUN adduser -D rdocker

WORKDIR /
COPY  --chown=rdocker:rdocker bootstrap.sh config.inc.sh env.inc.sh util.inc.sh rdocker.sh \
    /rdocker/
RUN chmod +x /rdocker/rdocker.sh

COPY --chown=rdocker:rdocker ./docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER rdocker
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /rdocker
CMD ["bash", "/rdocker/rdocker.sh"]
