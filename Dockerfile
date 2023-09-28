# Based on kylemanna/docker-openvpn

# Smallest base image, using alpine with glibc
FROM frolvlad/alpine-glibc:latest as build

RUN apk update && \
	apk add --update \
	  autoconf \
	  automake \
	  build-base \
	  libcap-ng-dev \
	  linux-headers \
	  openssl-dev 

# OpenVPN with XOR patches from Tunnelblick
COPY ./tunnelblick/third_party/sources/openvpn/openvpn-2.6.6/openvpn-2.6.6 /usr/src/openvpn-2.6.6

RUN cd /usr/src/openvpn-2.6.6 && \
	./configure \ 
	  --disable-lzo \
	  --disable-lz4 \
	  --disable-plugin-auth-pam \
	  --disable-systemd \
	  --enable-async-push \
	  --enable-iproute2 \
	  --enable-x509-alt-username && \
	make 

# Final image
FROM frolvlad/alpine-glibc:latest
RUN apk update && \
	apk upgrade --no-cache && \
    apk add --no-cache \
	  iptables \
	  iproute2-minimal \
	  bash \
	  easy-rsa \
	  libcap-ng \
	  openssl && \
	ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin 

COPY --from=build /usr/src/openvpn-2.6.6/src/openvpn/openvpn /usr/local/bin

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

CMD ["ovpn_run"]

# Copy scripts (by kylemanna)
COPY ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*
