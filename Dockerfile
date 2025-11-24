FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Update and install base packages in a single layer to reduce image size
RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        nano \
        git \
        gnupg \
        wget \
        build-essential \
        brightnessctl \
        python3 \
        autotools-dev \
        automake \
        libtool \
        libtool-bin \
        libevdev-dev \
        libdrm-dev \
        ninja-build \
        libopenal-dev \
        premake4 \
        autoconf \
        ffmpeg \
        libsnappy-dev \
        libboost-tools-dev \
        magics++ \
        libboost-thread-dev \
        libboost-all-dev \
        pkg-config \
        zlib1g-dev \
        libpng-dev \
        clang \
        libarchive13 \
        libcurl4 \
        libfreetype6-dev \
        libjsoncpp-dev \
        librhash0 \
        libuv1 \
        libgbm-dev \
        libsdl2-ttf-dev \
        libsdl2-image-dev \
        libsdl2-mixer-dev \
        libsdl-image1.2-dev \
        libsdl-mixer1.2-dev \
        libsdl-gfx1.2-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /usr/share/doc -depth -type f ! -name copyright -delete && \
    find /usr/share/man -type f -delete


# Add Kitware CMake repository
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt update && \
    apt install -y cmake && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install SDL2 for arm64
WORKDIR /root
RUN wget https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.2.tar.gz && \
    tar -xzf release-2.30.2.tar.gz && \
    cd SDL-release-2.30.2 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /root/SDL-release-2.30.2 /root/release-2.30.2.tar.gz

# Install libsdl1.2
WORKDIR /root
RUN git clone https://github.com/libsdl-org/sdl12-compat.git && \
    cd sdl12-compat && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF && \
    make -j$(nproc) && \
    make install && \
    rm -rf /root/sdl12-compat

# Install gl4es
WORKDIR /root
RUN git clone https://github.com/ptitSeb/gl4es.git && \
    cd gl4es && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON && \
    make -j$(nproc) && \
    make install && \
    rm -rf /root/gl4es

# Create symbolic link
RUN ln -sf /usr/include/libdrm/ /usr/include/drm

# Final cleanup
RUN apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
