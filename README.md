# lepong-deploy

Production deploy artifacts for [lepong](https://github.com/SotoAlt/lepong) — a
13M-parameter JEPA world model that plays Pong from pixels.

Runs on the JEPA inference VPS at `jepa.waweapps.win/lepong/` behind a Caddy
reverse proxy ([jepa-vps-proxy](https://github.com/SotoAlt/jepa-vps-proxy)).

## What's here

- `Dockerfile` — CPU-only PyTorch + FastAPI/uvicorn image
- `docker-compose.yml` — joins the shared external `web` Docker network
- `server/`, `model/`, `client/` — minimum source from the lepong repo
  needed to run the inference server (no training scripts, no datasets)
- `checkpoints/` — gitignored; populate via scp

## Deploy on a fresh VPS

Prereqs: Caddy proxy already running on the `web` network with `/lepong/*` →
`lepong:8791` routing (see jepa-vps-proxy repo).

```bash
ssh jepa-vps
cd /srv/lepong
git clone https://github.com/SotoAlt/lepong-deploy.git .
docker compose up -d --build
```

Then from your Mac, scp the checkpoint over (one-time per ckpt):

```bash
scp /path/to/jepa_pong_statehead_occ_aug.pt \
    jepa-vps:/srv/lepong/checkpoints/
ssh jepa-vps 'cd /srv/lepong && docker compose restart'
```

Verify: `curl https://jepa.waweapps.win/lepong/health`.

## Updating

```bash
ssh jepa-vps 'cd /srv/lepong && git pull && docker compose up -d --build'
```

Other apps on the VPS (caddy, relay, …) are not touched. That's the whole
point of the per-app compose project layout.
