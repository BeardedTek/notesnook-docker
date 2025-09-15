# nginx + certbot Setup

nginx provides high-performance reverse proxy with manual SSL certificate management via certbot.

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
NGINX_EMAIL=your-email@domain.com
```

### 2. Start nginx and certbot

```bash
cd docs/reverse-proxy/nginx
docker-compose up -d
```

### 3. Start Notesnook

```bash
cd ../../
USE_TRAEFIK=false ./start.sh
```

## Configuration Details

### SSL Certificate Management

Certbot automatically:
- Requests Let's Encrypt certificates
- Configures nginx with SSL settings
- Sets up automatic renewal
- Handles certificate challenges

### Service Routing

nginx routes traffic to your Notesnook services:

- `https://app.your-domain.com` → Notesnook Web App (port 8888)
- `https://notes.your-domain.com` → Notesnook API (port 5264)
- `https://auth.your-domain.com` → Identity Server (port 8264)
- `https://sse.your-domain.com` → SSE Server (port 7264)
- `https://monograph.your-domain.com` → Monograph Server (port 6264)
- `https://s3.your-domain.com` → MinIO API (port 9000)

### Security Features

The configuration includes:
- Security headers (HSTS, CSP, X-Frame-Options)
- Rate limiting
- SSL optimization
- HTTP/2 support
- Gzip compression

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
- Check Certbot logs: `docker-compose logs certbot`

### Services not accessible
- Check nginx configuration: `docker-compose exec nginx nginx -t`
- Verify service containers are running: `docker-compose ps`
- Check nginx logs: `docker-compose logs nginx`

### Useful Commands

```bash
# Test nginx configuration
docker-compose exec nginx nginx -t

# Reload nginx configuration
docker-compose exec nginx nginx -s reload

# Check certificate renewal
docker-compose exec certbot certbot certificates

# Force certificate renewal
docker-compose exec certbot certbot renew --force-renewal
```