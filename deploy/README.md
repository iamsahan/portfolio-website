# VPS reverse proxy (one-time setup)

Both `sahanweerakkody.me` (portfolio-website, port 3006) and
`os.sahanweerakkody.me` (portfolio-inner-site, port 3007) run behind a single
Caddy container that terminates TLS. This only needs to be set up once per
VPS — the app deploys (`.github/workflows/deploy.yml` in each repo) don't
touch it.

Before first use, point both DNS records at the VPS:
- `sahanweerakkody.me` → A record → VPS IP
- `os.sahanweerakkody.me` → A record → VPS IP

Then on the VPS:

```bash
mkdir -p /var/www/portfolio-proxy
scp deploy/Caddyfile deploy/docker-compose.yml user@vps:/var/www/portfolio-proxy/
ssh user@vps
cd /var/www/portfolio-proxy
docker compose up -d
```

Caddy automatically requests and renews Let's Encrypt certificates for both
domains on first request, and proxies to whichever app container is
currently published on ports 3006 / 3007 on that same host.
