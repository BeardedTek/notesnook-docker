# Traefik Setup

Traefik provides automatic SSL certificates and service discovery for your Notesnook instance.

## Prerequisites

- Domain name with DNS pointing to your server
- Ports 80 and 443 available
- Docker and Docker Compose installed

## Setup Steps

### 1. Create Traefik Network

```bash
docker network create traefik
```

### 2. Configure Environment

Update `env/traefik.env`:

```env
USE_TRAEFIK=true
```

Update `env/domain.env`:

```env
BASE_DOMAIN=your-domain.com
```

### 3. Start Traefik

```bash
cd docs/reverse-proxy/traefik
docker-compose up -d
```

### 4. Start Notesnook

```bash
cd ../../
./start.sh
```

## Configuration Details

### Automatic SSL

Traefik automatically:
- Requests Let's Encrypt certificates
- Renews certificates before expiration
- Redirects HTTP to HTTPS
- Handles certificate challenges

### Service Discovery

Services are configured with Docker labels:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.service.rule=Host(`subdomain.your-domain.com`)"
  - "traefik.http.routers.service.tls=true"
  - "traefik.http.routers.service.tls.certresolver=le"
```

### Dashboard

Access the Traefik dashboard at `https://traefik.your-domain.com` with:
- Username: `admin`
- Password: `admin` (change in docker-compose.yml)

## Verification

Check that all services are accessible via HTTPS:

- **Web App**: `https://app.your-domain.com`
- **API**: `https://notes.your-domain.com`
- **Auth**: `https://auth.your-domain.com`
- **SSE**: `https://sse.your-domain.com`
- **Sharing**: `https://monograph.your-domain.com`
- **Files**: `https://s3.your-domain.com`

## Troubleshooting

### Certificates not generating
- Verify DNS is pointing to your server
- Check ports 80/443 are accessible
- Ensure Traefik network exists: `docker network ls | grep traefik`

### Services not accessible
- Check Traefik logs: `docker-compose logs traefik`
- Verify service labels in docker-compose files
- Ensure services are connected to traefik network

### Useful Commands

```bash
# Check Traefik logs
docker-compose logs -f traefik

# Restart Traefik
docker-compose restart traefik

# Check certificate status
docker exec traefik cat /data/acme.json
```