# spinw-python Docker (macOS GUI via VNC)

Runs the spinw-python GUI inside Docker with a virtual X11 display (Xvfb) and streams
the window to your Mac via VNC.

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

Run the example code:

```bash
docker compose exec spinw python3 /workspace/test.py
```

## Stopping

```bash
docker compose down
```
