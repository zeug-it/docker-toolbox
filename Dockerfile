ARG DOCKER_VERSION=26.1.4-alpine3.20

FROM alpine:3.20 AS downloader
RUN apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

WORKDIR /usr/local/bin/
ENV DOCKER_MACHINE=https://gitlab-docker-machine-downloads.s3.amazonaws.com/main
RUN curl -fsSLo /usr/local/bin/docker-machine ${DOCKER_MACHINE}/docker-machine-$(uname -s)-$(uname -m) \
    && chmod +x /usr/local/bin/docker-machine


ARG MANIFEST_TOOL_VERSION="v2.1.6/manifest-tool-linux-amd64"
ENV MANIFEST_TOOL_BASE_URL=https://github.com/estesp/manifest-tool/releases/download
RUN echo "${MANIFEST_TOOL_BASE_URL}/${MANIFEST_TOOL_VERSION}" \
    && curl -sLo manifest-tool ${MANIFEST_TOOL_BASE_URL}/${MANIFEST_TOOL_VERSION} \
    && chmod +x manifest-tool

#ARG OPENFAASCLI_VERSION=0.16.29
#ARG OPENFAASCLI_SHA256

#ENV OPENFAASCLI_URL=https://github.com/openfaas/faas-cli/releases/download/${OPENFAASCLI_VERSION}/faas-cli
#RUN curl -fsSLo faas-cli ${OPENFAASCLI_URL} \
#    && echo "${OPENFAASCLI_SHA256} *faas-cli" | sha256sum -c - \
#    && chmod +x faas-cli

FROM docker:$DOCKER_VERSION
RUN apk add --no-cache \
    bash \
    bind-tools \
    ca-certificates \
    curl \
    gettext \
    git \
    jq \
    lftp \
    make \
    openssh-client \
    rsync

RUN apk add --no-cache \
    alpine-sdk \
    gcc \
    libffi-dev \
    openssl-dev \
    py3-pip \
    python3 \
    python3-dev 
#    && pip3 install --upgrade pip

#RUN pip3 install awscli
#RUN ls -l /usr/local/bin/


#ARG DOCKER_COMPOSE_VERSION=1.20.1
#ARG DOCKER_COMPOSE_SHA256
#ENV DOCKER_COMPOSE_URL=https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}
#RUN curl -sLo docker-compose ${DOCKER_COMPOSE_URL}/docker-compose-`uname -s`-`uname -m` \
#    && echo "$DOCKER_COMPOSE_SHA256 *docker-compose" | sha256sum -c - \
#    && chmod +x docker-compose

# install docker-compose via pip because of musl vs libc6
#ARG DOCKER_COMPOSE_VERSION=1.20.1
#RUN pip3 install docker-compose==$DOCKER_COMPOSE_VERSION

# copy precompiled docker-compose (linked to musl to work with alpine)
#COPY docker-compose /usr/local/bin/docker-compose

ENV SHELL=/bin/bash
COPY --from=downloader /usr/local/bin/ /usr/local/bin/

RUN { \
      docker-machine version; \
      docker compose version; \
      docker version || true; \
      faas-cli version || true; \
      manifest-tool --version || true; \
    }

WORKDIR /root
ENTRYPOINT []
CMD ["/bin/bash"]

COPY fs/ /
