# VPS reverse proxy (one-time setup)

This VPS already runs nginx as the front door for other projects, so the two
portfolio sites are added as ordinary nginx server blocks rather than a
separate proxy like Caddy — no need for a second thing listening on 80/443.

- `sahanweerakkody.me` (portfolio-website) → proxied to `127.0.0.1:3006`
- `os.sahanweerakkody.me` (portfolio-inner-site) → proxied to `127.0.0.1:3007`

This only needs to be done once per VPS — the app deploys
(`.github/workflows/deploy.yml` in each repo) don't touch nginx, they only
rebuild the app containers behind these ports.

## 1. DNS

Point both domains at the VPS IP (A records) before continuing — see
Namecheap Advanced DNS: `@` and `os` hosts on `sahanweerakkody.me`.

## 2. Add the nginx server blocks

```bash
scp deploy/sahanweerakkody.me.conf deploy/os.sahanweerakkody.me.conf user@vps:/tmp/
ssh user@vps
sudo mv /tmp/sahanweerakkody.me.conf /etc/nginx/sites-available/
sudo mv /tmp/os.sahanweerakkody.me.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/sahanweerakkody.me.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/os.sahanweerakkody.me.conf /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

(Adjust paths if this VPS's nginx doesn't use the `sites-available` /
`sites-enabled` convention — some setups drop config straight into
`/etc/nginx/conf.d/`.)

## 3. TLS

Use whatever already issues certs for the other domains on this box —
typically:

```bash
sudo certbot --nginx -d sahanweerakkody.me -d www.sahanweerakkody.me -d os.sahanweerakkody.me
```

Certbot rewrites the server blocks above to redirect port 80 → 443 and adds
the `ssl_certificate` lines automatically.

## 4. Verify

Once the app containers are deployed and listening on 3006/3007
(`docker compose up -d` in each repo's directory), both domains should
proxy through correctly:

```bash
curl -I https://sahanweerakkody.me
curl -I https://os.sahanweerakkody.me
```
