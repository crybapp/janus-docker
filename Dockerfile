FROM debian:bookworm-slim AS builder
WORKDIR /build

RUN apt-get update && apt-get install -y \
	git \
	make \
	automake \
	pkg-config \
	libconfig-dev \
	libcurl4-openssl-dev \
	libglib2.0-dev \
	libjansson-dev \
	liblua5.3-dev \
	libmicrohttpd-dev \
	libnice-dev \
	libopus-dev \
	libogg-dev \
	libssl-dev \
	libsrtp2-dev \
	libsofia-sip-ua-dev \
	libtool \
	meson

RUN git clone https://github.com/meetecho/janus-gateway.git \
	&& cd janus-gateway \
	&& git checkout v1.2.4 \
	&& sh autogen.sh \
	&& ./configure \
		--enable-dependency-tracking \
		--enable-libsrtp2 \
		--disable-all-plugins \
		--disable-all-handlers \
		--enable-rest \
		--enable-plugin-streaming \
		--disable-unix-sockets \
		--prefix=/opt/janus \
	&& make -j$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}') \
	&& make install

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
	libconfig9 \
	libcurl4 \
	libjansson4 \
	libmicrohttpd12 \
	libnice10 \
	libssl3 \
	libsrtp2-1 \
	libogg0 \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY --from=builder /opt/janus /opt/janus
COPY configs/janus.jcfg configs/janus.plugin.streaming.jcfg configs/janus.transport.http.jcfg /opt/janus/etc/janus/

ENTRYPOINT [ "/opt/janus/bin/janus" ]
