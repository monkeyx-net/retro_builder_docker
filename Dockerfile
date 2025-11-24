# Build stage
FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates \
        sudo \
        git \
        curl \
        wget \
        build-essential \
        automake \
        libtool \
        ninja-build \
        autoconf \
        cmake \
        pkg-config \
        zlib1g-dev \
        libevdev-dev \
        libdrm-dev \
        libgbm-dev \
        libopenal-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Build SDL2
WORKDIR /tmp
RUN wget https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.2.tar.gz && \
    tar -xzf release-2.30.2.tar.gz && \
    cd SDL-release-2.30.2 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install

# Build sdl12-compat
RUN git clone https://github.com/libsdl-org/sdl12-compat.git && \
    cd sdl12-compat && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF && \
    make -j$(nproc) && \
    make install

# Build gl4es
RUN git clone https://github.com/ptitSeb/gl4es.git && \
    cd gl4es && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON && \
    make -j$(nproc) && \
    make install

# Final stage
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Install only runtime dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates \
        libevdev2 \
        libdrm2 \
        libgbm1 \
        libopenal1 \
        libsdl2-2.0-0 \
        libsdl2-ttf-2.0-0 \
        libsdl2-image-2.0-0 \
        libsdl2-mixer-2.0-0 \
        zlib1g \
        libfreetype6 \
        libjsoncpp1 \
        libuv1 \
        libarchive13 \
        libcurl4 \
        librhash0 \
        ffmpeg \
        libsnappy1v5 \
        magics++ \
        python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    find /usr/share/doc -depth -type f ! -name copyright -delete && \
    find /usr/share/man -type f -delete

# Copy built libraries from builder stage
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/include /usr/include
COPY --from=builder /usr/local /usr/local

RUN ldconfig && \
    ln -sf /usr/include/libdrm/ /usr/include/drm
