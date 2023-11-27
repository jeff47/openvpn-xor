# Uses scripts from kylemanna/docker-openvpn

# Update this to point to the current version of openvpn (must be in the Tunnelblick repo)
ARG openvpn_version=openvpn-2.6.8

# Smallest base image, using alpine with glibc
FROM frolvlad/alpine-glibc:latest as build

ARG openvpn_version

RUN apk update && \
	apk add --update \
	  autoconf \
	  automake \
	  build-base \
	  libcap-ng-dev \
	  linux-headers \
	  openssl-dev 

# OpenVPN with XOR patches from Tunnelblick
COPY ./Tunnelblick/third_party/sources/openvpn/$openvpn_version/ /usr/src

RUN cd /usr/src \
  && tar xf $openvpn_version.tar.gz  \
  && cd /usr/src/$openvpn_version \
  && patch -p1 < ../patches/02-tunnelblick-openvpn_xorpatch-a.diff \
  && patch -p1 < ../patches/03-tunnelblick-openvpn_xorpatch-b.diff \
  && patch -p1 < ../patches/04-tunnelblick-openvpn_xorpatch-c.diff \
  && patch -p1 < ../patches/05-tunnelblick-openvpn_xorpatch-d.diff \
  && patch -p1 < ../patches/06-tunnelblick-openvpn_xorpatch-e.diff \
  && patch -p1 < ../patches/10-route-gateway-dhcp.diff

RUN cd /usr/src/$openvpn_version && \
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
ARG openvpn_version

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

COPY --from=build /usr/src/$openvpn_version/src/openvpn/openvpn /usr/local/bin

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
