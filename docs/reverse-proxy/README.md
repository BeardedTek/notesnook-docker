# Reverse Proxy Setup

This guide covers setting up reverse proxies with automatic SSL certificates for your Notesnook instance. Choose the option that best fits your needs.

## Available Options

- [Traefik](./traefik/README.md) - Automatic SSL with Traefik
- [nginx + certbot](./nginx/README.md) - Manual SSL with nginx and certbot  
- [Caddy](./caddy/README.md) - Automatic SSL with Caddy

## Prerequisites

Before setting up a reverse proxy, ensure you have:

- A domain name with DNS control
- The domain pointing to your server's IP address
- Ports 80 and 443 open on your firewall
- Docker and Docker Compose installed

## Common Configuration

Regardless of which reverse proxy you choose, you'll need to:

### 1. Enable Traefik in Configuration

Set in `env/traefik.env`:

```env
USE_TRAEFIK=true
```

### 2. Configure Your Domain

Update `env/domain.env`:

```env
BASE_DOMAIN=your-domain.com
```

### 3. Set Server URLs

Update `env/servers.env` with your domain:

```env
NOTESNOOK_SYNC_PUBLIC_URL=https://notes.your-domain.com
NOTESNOOK_APP_PUBLIC_URL=https://app.your-domain.com
MONOGRAPH_PUBLIC_URL=https://monograph.your-domain.com
AUTH_SERVER_PUBLIC_URL=https://auth.your-domain.com
ATTACHMENTS_SERVER_PUBLIC_URL=https://s3.your-domain.com
SSE_SERVER_PUBLIC_URL=https://sse.your-domain.com
```

## DNS Configuration

Point the following subdomains to your server:

```
notes.your-domain.com     -> YOUR_SERVER_IP
app.your-domain.com       -> YOUR_SERVER_IP
monograph.your-domain.com -> YOUR_SERVER_IP
auth.your-domain.com      -> YOUR_SERVER_IP
s3.your-domain.com        -> YOUR_SERVER_IP
sse.your-domain.com       -> YOUR_SERVER_IP
```

## Starting with Reverse Proxy

Once configured, start the services:

```bash
./start.sh
```

The script will automatically load the appropriate reverse proxy configuration based on your settings.

## Access Your Instance

After starting, access your instance at:

- **Notesnook Web App**: https://app.your-domain.com
- **API Server**: https://notes.your-domain.com
- **Authentication**: https://auth.your-domain.com
- **File Storage**: https://s3.your-domain.com
- **Real-time Updates**: https://sse.your-domain.com
- **Public Sharing**: https://monograph.your-domain.com

## Troubleshooting

- **SSL Certificate Issues**: Ensure your domain DNS is properly configured before starting
- **502 Bad Gateway**: Check that all services are running and healthy
- **CORS Errors**: Verify all URLs in `env/servers.env` use HTTPS
- **Connection Refused**: Ensure ports 80 and 443 are open on your firewall