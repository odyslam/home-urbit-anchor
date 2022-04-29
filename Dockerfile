FROM golang:1.17.1-alpine3.14 AS wireguard-go

# hadolint ignore=DL3018
RUN apk add --no-cache -t build-deps curl build-base libc-dev gcc libgcc

WORKDIR /usr/src/app

ARG WG_GO_TAG=0.0.20210212

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN curl -fsSL https://git.zx2c4.com/wireguard-go/snapshot/wireguard-go-${WG_GO_TAG}.tar.xz | tar xJ && \
    make -C wireguard-go-${WG_GO_TAG} -j"$(nproc)" && \
    make -C wireguard-go-${WG_GO_TAG} install

# Initial setup for webhook
#ENV WEBHOOK_VERSION "2.8.0"

# RUN curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
#     tar -xzf webhook.tar.gz --strip 1 &&  \
#     go get -d && \
#     go build -o /usr/local/bin/webhook && \
#     apk del --purge build-deps && \
#     rm -rf /var/cache/apk/* && \
#     rm -rf /go

FROM alpine:3.14

COPY --from=wireguard-go /usr/bin/wireguard-go /usr/bin/
#COPY --from=wireguard-go /usr/local/bin/webhook /usr/bin/

# hadolint ignore=DL3018
RUN apk add --update --no-cache \
    bash \
    build-base \
    curl \
    libmnl-dev \
    iptables \
    flex \
    bison \
    bc \
    python3 \
    kmod \
    openresolv \
    iproute2 \
    kmod \
    libqrencode \
    gettext \
    ipcalc \
    openssl-dev \
    perl \
    neovim \
    jq

WORKDIR /usr/src/app

ARG WITH_WGQUICK=yes
ARG WG_TOOLS_TAG=v1.0.20210424
ARG WG_LINUX_TAG=v1.0.20210606

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN curl -fsSL https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-${WG_TOOLS_TAG}.tar.xz | tar xJ && \
    curl -fsSL https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat-${WG_LINUX_TAG}.tar.xz | tar xJ

# build and install wireguard-tools
RUN make -C wireguard-tools-${WG_TOOLS_TAG}/src -j"$(nproc)" && \
    make -C wireguard-tools-${WG_TOOLS_TAG}/src install

COPY wireguard-linux-compat.patch ./
RUN patch -d /usr/src/app/wireguard-linux-compat-${WG_LINUX_TAG}/ -p0 < wireguard-linux-compat.patch


# COPY buildmod.sh ./
# RUN chmod +x ./buildmod.sh && ./buildmod.sh

WORKDIR /usr/src/app/templates

COPY server.conf ./

WORKDIR /usr/src/app

RUN curl -fsSL https://raw.githubusercontent.com/honzahommer/prips.sh/8bfab5e17539b37f1d21584da19e79f8751d6846/libexec/prips.sh -O && \
    chmod +x prips.sh

COPY run.sh ./

COPY show-peer /usr/bin/

RUN chmod +x run.sh /usr/bin/show-peer

COPY template /etc/wireguard/template
COPY nextip /usr/sbin/nextip

RUN chmod +x /usr/sbin/nextip

VOLUME [ "/mnt/conf" ]
EXPOSE 51820

CMD [ "/usr/src/app/run.sh" ]

# set defaults for wireguard server
ENV SERVER_HOST "auto"
ENV SERVER_PORT "51820"
ENV CIDR "10.13.13.0/24"
ENV ALLOWEDIPS "0.0.0.0/0, ::/0"
ENV PEER_DNS "1.1.1.1"
ENV PEERS "4"

# set log level for userspace module
ENV LOG_LEVEL "verbose"
