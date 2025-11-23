FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Fix package dependencies first
RUN apt update && \
    apt install -y --fix-broken && \
    apt install -y apt-utils && \
    dpkg --configure -a

# Install Python separately first to avoid dependency issues
RUN apt update && \
    apt install -y \
    python3 \
    python3-minimal \
    python3-setuptools \
    python3-wheel && \
    dpkg --configure -a

# Now install pip after setuptools is configured
RUN apt install -y python3-pip && \
    dpkg --configure -a

# Install the rest of the packages in smaller groups
RUN apt install -y \
    sudo \
    git \
    curl \
    nano \
    wget \
    build-essential \
    brightnessctl && \
    dpkg --configure -a

RUN apt install -y \
    autotools-dev \
    automake \
    libtool \
    libtool-bin \
    libevdev-dev \
    libdrm-dev \
    ninja-build \
    libopenal-dev && \
    dpkg --configure -a

RUN apt install -y \
    premake4 \
    autoconf \
    ffmpeg \
    libsnappy-dev \
    libboost-tools-dev \
    magics++ \
    libboost-thread-dev \
    libboost-all-dev && \
    dpkg --configure -a

RUN apt install -y \
    pkg-config \
    zlib1g-dev \
    libpng-dev \
    libsdl2-dev \
    libsdl1.2-dev \
    clang && \
    dpkg --configure -a

RUN apt install -y \
    libarchive13 \
    libcurl4 \
    libfreetype6-dev \
    libjsoncpp-dev \
    librhash0 \
    libuv1 \
    mercurial \
    mercurial-common && \
    dpkg --configure -a

RUN apt install -y \
    libgbm-dev \
    libsdl2-ttf-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl-image1.2-dev \
    libsdl-mixer1.2-dev \
    libsdl-gfx1.2-dev && \
    dpkg --configure -a

# Final package cleanup
RUN apt update && \
    apt install -y --fix-broken && \
    dpkg --configure -a && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/include/libdrm/ /usr/include/drm

# Install meson using ensurepip to avoid system conflicts
RUN python3 -m pip install --upgrade pip && \
    pip install cmake --upgrade cmake && \
    pip install meson

# Install libsdl1.2
WORKDIR /root
RUN git clone https://github.com/libsdl-org/sdl12-compat.git && \
    cd sdl12-compat && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF && \
    make -j2


# Install SDL2 for arm64
WORKDIR /root
RUN wget https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.26.2.tar.gz && \
    tar -xzf release-2.26.2.tar.gz && \
    cd SDL-release-2.26.2 && \
    ./configure --prefix=/usr && \
    make -j2 && \
    make install && \
    ldconfig

# Install gl4es
WORKDIR /root
RUN git clone https://github.com/ptitSeb/gl4es.git && \
    cd gl4es && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON && \
    make

# Final cleanup
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/sdl12-compat /root/gl4es /root/SDL-release-2.26.2 /root/release-2.26.2.tar.gz
