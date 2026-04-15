# spinw-python Docker (macOS GUI via VNC)

Runs the spinw-python GUI inside Docker with a virtual X11 display (Xvfb) and streams
the window to your Mac via VNC. No XQuartz required.

## Prerequisites

You need **Docker** running on your Mac. Two options:

- **OrbStack** (recommended on Apple Silicon — faster, lighter, free for personal use):
  ```bash
  brew install --cask orbstack
  ```
- **Docker Desktop** (official):
  ```bash
  brew install --cask docker
  ```
  Then open Docker Desktop from Applications once to finish setup.

Verify it works:
```bash
docker --version
docker compose version
```

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

> **Important:** Run the container in **attached mode** (`docker compose up`, no `-d`).
> The container's main process is an interactive Python shell, which exits immediately
> if no terminal is attached. Open a second terminal for `docker compose exec` commands.

```bash
# 1. Start the container (attached — keeps Python REPL alive)
docker compose up

# 2. Open TigerVNC and connect to localhost:5900 (leave password blank)

# 3. Run your scripts inside the container
docker compose exec spinw python3 /workspace/your_script.py
```

Your `./workspace/` folder on the Mac is mounted at `/workspace` inside the container —
edit scripts locally in any editor, then run them in the container. Any GUI window
(`view(s)`, `sw.plot()`, etc.) will appear in the TigerVNC window.

## Example

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

**Container exits immediately** — you used `docker compose up -d` (detached). Don't.
The container's main process is an interactive Python shell, which has no terminal
attached in detached mode and exits right away. Run `docker compose up` (without `-d`)
in one terminal, and use a second terminal for `docker compose exec` commands.

**Rebuild after Dockerfile changes:**

```bash
docker compose down
docker compose build
docker compose up
```
