# Caddy Setup

Caddy provides automatic HTTPS with zero-configuration SSL certificates.

## Prerequisites

- Domain name with DNS pointing to your server
- Ports 80 and 443 available
- Docker and Docker Compose installed

## Setup Steps

### 1. Configure Environment

Update `env/domain.env`:

```env
BASE_DOMAIN=your-domain.com
```

Add to your `.env` file:

```env
CADDY_EMAIL=your-email@domain.com
```

### 2. Start Caddy

```bash
cd docs/reverse-proxy/caddy
docker-compose up -d
```

### 3. Start Notesnook

```bash
cd ../../
USE_TRAEFIK=false ./start.sh
```

## Configuration Details

### Automatic HTTPS

Caddy automatically:
- Obtains SSL certificates from Let's Encrypt
- Renews certificates before expiration
- Redirects HTTP to HTTPS
- Uses modern TLS configurations
- Supports HTTP/2 and HTTP/3

### Service Routing

Caddy routes traffic to your Notesnook services:

- `https://app.your-domain.com` → Notesnook Web App (port 8888)
- `https://notes.your-domain.com` → Notesnook API (port 5264)
- `https://auth.your-domain.com` → Identity Server (port 8264)
- `https://sse.your-domain.com` → SSE Server (port 7264)
- `https://monograph.your-domain.com` → Monograph Server (port 6264)
- `https://s3.your-domain.com` → MinIO API (port 9000)

### Simple Configuration

The Caddyfile uses readable syntax:

```
app.your-domain.com {
    reverse_proxy host.docker.internal:8888
    header Strict-Transport-Security "max-age=31536000; includeSubDomains"
}
```

## Verification

Check that all services are accessible via HTTPS:

- **Web App**: `https://app.your-domain.com`
- **API**: `https://notes.your-domain.com`
- **Auth**: `https://auth.your-domain.com`
- **SSE**: `https://sse.your-domain.com`
- **Sharing**: `https://monograph.your-domain.com`
- **Files**: `https://s3.your-domain.com`

## Troubleshooting

### SSL certificates not generating
- Verify DNS is pointing to your server
- Check ports 80/443 are accessible
- Ensure email address is valid in `.env`
- Check Caddy logs: `docker-compose logs caddy`

### Services not accessible
- Check Caddy configuration: `docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile`
- Verify service containers are running: `docker-compose ps`
- Check Caddy logs: `docker-compose logs caddy`

### Useful Commands

```bash
# Test Caddy configuration
docker-compose exec caddy caddy validate --config /etc/caddy/Caddyfile

# Reload Caddy configuration
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile

# Check certificate status
docker-compose exec caddy caddy list-certificates

# Force certificate renewal
docker-compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```