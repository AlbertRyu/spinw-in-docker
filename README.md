# spinw-python Docker (macOS GUI via VNC)

> ⚠️ **Heads-up:** This is a quick fix put together with the help of Claude Code.
> It works on my machine (M3 MacBook Air 15"), but there's no guarantee it will
> work on every MacBook. :)

Runs the spinw-python GUI inside Docker with a virtual X11 display (Xvfb) and streams
the window to your Mac via VNC.

## What is the current problem on the Mac

spinw's viewer is built on a higher version of **OpenGL**. However, Apple has dropped the support of OpenGL years ago and mac users are stucked with the old version.

This workaround is to do all the rendering **inside the container** using Mesa's software
rasterizer (`llvmpipe`), draw into a virtual X11 display (`Xvfb`), and then stream that
display to your Mac via VNC. Your Mac only has to display a stream of pixels — it never
sees an OpenGL call.

> ⚠️ **Performance warning:** VNC works by continuously capturing and transmitting screenshots of a virtual display, so expect noticeable latency when rotating or zooming 3D views. This is fine for inspecting structures and results, but don't expect native smoothness. A Windows VM via Parallels would perform better, but requires much more RAM than my 8 GB Macbook Air can comfortably spare. :(

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

2. **Clone this repository** (or download it as a ZIP and extract it):

   ```bash
   git clone https://github.com/AlbertRyu/spinw-in-docker.git
   ```

3. **Enter the repo folder** — all following commands must be run from inside it:

   ```bash
   cd spinw-in-docker
   ```

4. **Build the Docker image:**

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
such as `view(s)` will appear in the TigerVNC window.

## Example

Run the example code:

```bash
docker compose exec spinw python3 /workspace/test.py
```

## Stopping

```bash
docker compose down
```

## Updating spinw-python

**Quick (inside the running container, temporary):**

```bash
docker compose exec spinw pip install --upgrade spinw-python
```

The upgrade is lost when the container is recreated.

**Permanent (rebuild the image):**

Docker caches the `pip install` layer, so a plain `docker compose build` won't pick up
a new version. Force the pip step to rerun:

```bash
docker compose build --no-cache
```

Thanks to the BuildKit pip cache mount, unchanged packages still come from cache —
this is much faster than a true fresh build.

**To pin a specific version**, edit the Dockerfile line:

```dockerfile
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install spinw-python==0.5.2
```

Then run `docker compose build` — changing the Dockerfile invalidates that layer
automatically, no `--no-cache` needed.
