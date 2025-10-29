# Use Kitware repo for newer CMake
FROM --platform=linux/arm64 ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Base utilities and Kitware repo
RUN apt update && apt install -y --no-install-recommends \
    ca-certificates gnupg wget && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main" \
      > /etc/apt/sources.list.d/kitware.list && \
    apt update && apt install -y --no-install-recommends cmake cmake-data && \
    rm -rf /var/lib/apt/lists/*

# Build dependencies
RUN apt update && apt install -y --no-install-recommends \
    build-essential git wget curl python3 python3-pip pkg-config ninja-build clang \
    automake autoconf libtool \
    libudev-dev libdbus-1-dev libx11-dev libxext-dev libxrandr-dev libxfixes-dev libxi-dev libxcursor-dev \
    libxinerama-dev libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev \
    libasound2-dev libpulse-dev libfreetype6-dev libpng-dev zlib1g-dev \
    libopenal-dev libsnappy-dev libjsoncpp-dev ffmpeg libboost-all-dev \
    mercurial && \
    rm -rf /var/lib/apt/lists/*

# Python tools
RUN pip install --no-cache-dir meson ninja

# --- Build SDL2 from source ---
WORKDIR /root
RUN wget https://github.com/libsdl-org/SDL/releases/download/release-2.26.2/SDL2-2.26.2.tar.gz && \
    tar -xzf SDL2-2.26.2.tar.gz && cd SDL2-2.26.2 && \
    ./configure --prefix=/usr \
        --disable-wayland --disable-wayland-shared \
        --enable-video-x11 --enable-video-kmsdrm \
        --disable-video-vivante --disable-video-opengles --disable-video-opengles1 --disable-video-opengles2 && \
    make -j2 && make install && ldconfig && \
    cd /root && rm -rf SDL2-2.26.2 SDL2-2.26.2.tar.gz

# --- Build sdl12-compat ---
WORKDIR /root
RUN git clone https://github.com/libsdl-org/sdl12-compat.git && \
    cd sdl12-compat && mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j2 && make install && \
    ldconfig && \
    cd /root && rm -rf sdl12-compat

# --- Build gl4es ---
WORKDIR /root
RUN git clone https://github.com/ptitSeb/gl4es.git && \
    cd gl4es && mkdir build && cd build && \
    cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON -DWAYLAND=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -j2 && make install && \
    cd /root && rm -rf gl4es

# Final cleanup
RUN apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /workspace
