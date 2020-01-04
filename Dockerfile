FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
    git \
    wget \
    gtk-doc-tools \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libglib2.0-dev \
    libcurl4-openssl-dev \
    libconfig-dev \
    libffi-dev \
    libmount-dev \
    gettext \
    pkg-config \
    gengetopt \
    libtool \ 
    make \
    automake

RUN wget https://github.com/GNOME/glib/archive/2.54.3.tar.gz && \
    tar xfv 2.54.3.tar.gz && \
    cd glib-2.54.3 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd ../ && \
    rm -rf 2.54.3.tar.gz && \
    rm -rf glib-2.54.3

RUN apt-get purge -y libnice-dev && \
    git clone https://gitlab.freedesktop.org/libnice/libnice && \
    cd libnice && \
    ./autogen.sh --disable-dependency-tracking && \
    ./configure --disable-dependency-tracking --prefix=/usr  && \
    make && \
    make install && \
    cd ../ && \
    rm -rf libnice

RUN wget https://github.com/cisco/libsrtp/archive/v1.5.4.tar.gz && \
    tar xfv v1.5.4.tar.gz && \
    cd libsrtp-1.5.4 && \
    ./configure --prefix=/usr --enable-openssl && \
    make shared_library && \
    make install && \
    cd ../ && \
    rm -rf v1.5.4.tar.gz && \
    rm -rf libsrtp-1.5.4

RUN git clone https://github.com/meetecho/janus-gateway.git && \
    cd janus-gateway && \
    sh autogen.sh --disable-libsrtp-2 && \
    ./configure --disable-all-plugins --disable-all-handlers --enable-rest --enable-plugin-streaming --disable-unix-sockets --disable-libsrtp-2 && \
    make && \
    make install && \
    cd ../ && \
    rm -rf janus-gateway 

COPY configs/janus.jcfg configs/janus.plugin.streaming.jcfg configs/janus.transport.http.jcfg /usr/local/etc/janus/

ENTRYPOINT [ "janus" ]
