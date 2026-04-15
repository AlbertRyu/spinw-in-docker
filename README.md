# spinw-python Docker (macOS GUI via VNC)

Runs the spinw-python GUI inside Docker with a virtual X11 display (Xvfb) and streams
the window to your Mac via VNC. No XQuartz required.

## One-time setup

1. **Install TigerVNC Viewer** on your Mac:
   ```bash
   brew install --cask tigervnc-viewer
   ```

2. **Build the Docker image:**
   ```bash
   docker compose build
   ```
   First build downloads system and Python dependencies (~5-10 min).
   Subsequent builds reuse the apt/pip cache thanks to BuildKit cache mounts.

## Usage

```bash
# 1. Start the container in the background
docker compose up -d

# 2. Open TigerVNC and connect to localhost:5900 (leave password blank)

# 3. Run your scripts inside the container
docker compose exec spinw python3 /workspace/your_script.py
```

Your `./workspace/` folder on the Mac is mounted at `/workspace` inside the container —
edit scripts locally in any editor, then run them in the container. Any GUI window
(`view(s)`, `sw.plot()`, etc.) will appear in the TigerVNC window.

## Example

`workspace/test.py`:
```python
import signal
signal.signal(signal.SIGINT, signal.SIG_DFL)  # allow Ctrl+C to kill Qt window

import pyspinw
s = pyspinw.SpinW()
# ... define your model ...
s.view()
```

Run it:
```bash
docker compose exec spinw python3 /workspace/test.py
```

## Stopping

```bash
docker compose down
```

To force-close a stuck Python viewer without killing the container:
```bash
docker compose exec spinw pkill -9 python3
```

## How it works

```
Qt app ──X11──▶ Xvfb ──VNC──▶ TigerVNC on Mac
         ▲
         │
      openbox (X11 window manager)
```

- **Xvfb** — virtual X11 server running in the container (display `:99`)
- **openbox** — lightweight X11 window manager (provides title bars and close buttons)
- **x11vnc** — captures the X11 display and streams it as VNC on port 5900
- **TigerVNC** on your Mac — receives the VNC stream

Everything OpenGL-related runs inside the container using Mesa's software renderer
(`llvmpipe`), so no GPU passthrough or XQuartz quirks are involved.

## Troubleshooting

**`service "spinw" is not running`** — you forgot `docker compose up -d` before `exec`.

**TigerVNC asks for a password** — leave it blank and connect.

**Window has no title bar / close button** — openbox didn't start. Check logs with
`docker compose logs spinw`.

**`Ctrl+C` doesn't close the viewer** — Qt intercepts `SIGINT`. Add
`signal.signal(signal.SIGINT, signal.SIG_DFL)` to the top of your script, or use
`Ctrl+\` (SIGQUIT), or run `docker compose exec spinw pkill -9 python3`.

**Rebuild after Dockerfile changes:**
```bash
docker compose down
docker compose build
docker compose up -d
```
