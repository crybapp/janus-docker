FROM alpine:edge

RUN apk --no-cache upgrade && apk add --no-cache \
    git \
    wget \
    gtk-doc \
	glib \
    libmicrohttpd-dev \
    jansson-dev \
    openssl-dev \
    curl-dev \
    libconfig-dev \
    libffi-dev \
	libsrtp-dev \
    gettext \
    pkgconfig \
    gengetopt \
    libtool \ 
    make \
    automake \
	autoconf \
	alpine-sdk

RUN apk del --no-cache libnice-dev && \
    git clone https://gitlab.freedesktop.org/libnice/libnice && \
    cd libnice && \
    ./autogen.sh --disable-dependency-tracking && \
    ./configure --disable-dependency-tracking --prefix=/usr  && \
    make && \
    make install && \
    cd ../ && \
    rm -rf libnice

RUN git clone https://github.com/meetecho/janus-gateway.git && \
    cd janus-gateway && \
    sh autogen.sh --disable-libsrtp-2 && \
    ./configure --disable-all-plugins --disable-all-handlers --enable-rest --enable-plugin-streaming --disable-unix-sockets --disable-libsrtp-2 && \
    make && \
    make install && \
    cd ../ && \
    rm -rf janus-gateway 

COPY configs/janus.jcfg configs/janus.plugin.streaming.jcfg configs/janus.transport.http.jcfg /usr/local/etc/janus/

EXPOSE 8088

ENTRYPOINT [ "janus" ]
