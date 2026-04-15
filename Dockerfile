FROM --platform=linux/amd64 python:3.12-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies — apt cache persists across builds via BuildKit
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    python3-dev \
    build-essential \
    cmake \
    git \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxi6 \
    libxrandr2 \
    libxfixes3 \
    libxcursor1 \
    libxinerama1 \
    libxtst6 \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libegl1-mesa \
    libopengl0 \
    mesa-utils \
    libllvm14 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xfixes0 \
    libxcb-shape0 \
    libxcb-util1 \
    libxcb-cursor0 \
    libglib2.0-0 \
    libdbus-1-3 \
    libfontconfig1 \
    libfreetype6 \
    libxkbcommon-x11-0 \
    xvfb \
    x11vnc \
    openbox \
    x11-utils

# Python dependencies — pip cache persists across builds via BuildKit
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install spinw-python

# Runtime environment variables — changing these does NOT trigger reinstall
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV MESA_LOADER_DRIVER_OVERRIDE=swrast
ENV GALLIUM_DRIVER=llvmpipe
ENV QT_X11_NO_MITSHM=1
ENV QT_QPA_PLATFORM=xcb
ENV DISPLAY=:99

WORKDIR /workspace

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
