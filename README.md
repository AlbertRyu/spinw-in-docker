# spinw-python Docker (macOS GUI via XQuartz)

Runs the spinw-python GUI inside Docker and forwards the window to your Mac via X11.

## One-time setup

1. **Install XQuartz** (the X11 server for macOS):
   ```bash
   brew install --cask xquartz
   ```
   Then log out and back in (or reboot) so XQuartz is fully active.

2. **Allow network connections in XQuartz:**
   Open XQuartz → Preferences → Security → check **"Allow connections from network clients"**

3. **Build the Docker image:**
   ```bash
   docker compose build
   ```

## Usage

Each time you want to use spinw:

```bash
# 1. Allow X11 connections from localhost
xhost + localhost

# 2. Start an interactive Python session inside the container
docker compose run spinw python3
```

Your `./workspace/` folder is mounted at `/workspace` inside the container — put your scripts and data files there.

## Example

```python
>>> import pyspinw
>>> # use spinw normally; GUI windows will appear on your Mac
```

## Troubleshooting

**`could not connect to display`** — XQuartz is not running or you forgot `xhost + localhost`.

**Blank/black window** — `LIBGL_ALWAYS_SOFTWARE=1` forces Mesa's software renderer. If it's already
set and windows are blank, try adding `LIBGL_DEBUG=verbose` to the environment to see what's failing.

**`xcb` platform errors** — The xcb Qt platform plugin dependencies are all included in the image.
If you see a missing `.so`, re-run `docker compose build --no-cache`.
