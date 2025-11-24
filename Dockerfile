FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

RUN apt update && \
    apt install -y --no-install-recommends \
        ca-certificates \
        git \
        wget \
        build-essential \
        cmake \
        pkg-config \
        zlib1g-dev \
        libevdev-dev \
        libdrm-dev \
        libgbm-dev \
        libegl-dev \
        libgles2-mesa-dev \
        libfreetype6-dev \
        libopenal-dev \
        libjsoncpp-dev \
        ffmpeg \
        python3 && \
    # Build SDL2
    cd /tmp && \
    wget -q https://github.com/libsdl-org/SDL/archive/refs/tags/release-2.30.2.tar.gz && \
    tar -xzf release-2.30.2.tar.gz && \
    cd SDL-release-2.30.2 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    # Build sdl12-compat
    cd /tmp && \
    git clone --depth 1 https://github.com/libsdl-org/sdl12-compat.git && \
    cd sdl12-compat && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF && \
    make -j$(nproc) && \
    make install && \
    # Build gl4es
    cd /tmp && \
    git clone --depth 1 https://github.com/ptitSeb/gl4es.git && \
    cd gl4es && \
    mkdir build && cd build && \
    cmake .. -DSDL12TESTS=OFF -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON && \
    make -j$(nproc) && \
    make install && \
    # Cleanup
    apt autoremove -y --purge && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /usr/share/doc -depth -type f ! -name copyright -delete && \
    find /usr/share/man -type f -delete

RUN ldconfig && \
    ln -sf /usr/include/libdrm/ /usr/include/drm
