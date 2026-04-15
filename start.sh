#!/bin/bash
# Start virtual display
Xvfb :99 -screen 0 1280x1024x24 &

# Wait until Xvfb is ready
until xdpyinfo -display :99 >/dev/null 2>&1; do sleep 0.1; done

# Start window manager
DISPLAY=:99 openbox &

# Start VNC server
x11vnc -display :99 -nopw -forever -bg -quiet

# Drop into Python
exec python3
