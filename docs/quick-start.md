# Quick Start Guide

This guide will help you get Notesnook running quickly using self-hosted MinIO with direct port access (no reverse proxy required).

## Prerequisites

- Docker and Docker Compose installed
- SMTP server credentials for email notifications
- Basic understanding of Docker

## Step 1: Clone and Setup

```bash
git clone <your-repo-url>
cd notesnook-docker
```

## Step 2: Environment Configuration

### Option A: Interactive Configuration (Recommended)

Run the interactive configuration script:

```bash
./configure.sh
```

This will guide you through setting up all the required configuration with validation and helpful prompts.

### Option B: Manual Configuration

Configure your environment variables by editing the files in the `env/` directory. The files are organized by category for easy configuration:

### Basic Configuration (`env/basic.env`)

```env
INSTANCE_NAME=my-notesnook-instance
NOTESNOOK_API_SECRET=your-secure-api-secret-32-chars-minimum
DISABLE_SIGNUPS=false
```

### Domain Configuration (`env/domain.env`)

```env
BASE_DOMAIN=your-domain.com
```

### SMTP Configuration (`env/smtp.env`)

```env
SMTP_USERNAME=your-email@domain.com
SMTP_PASSWORD=your-smtp-password
SMTP_HOST=smtp.your-domain.com
SMTP_PORT=587
```

### S3 Configuration (`env/s3.env`)

```env
SELF_HOST_S3=true
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=your-secure-minio-password
```

### Web App Configuration (`env/webapp.env`)

```env
USE_WEB_APP=true
```

### Traefik Configuration (`env/traefik.env`)

```env
USE_TRAEFIK=false
```

**Optional**: You can also create a `.env` file in the root directory to override any settings from the `env/` files if needed.

## Step 3: Generate Required Secrets

Generate a secure API secret (32+ characters):

```bash
# Using openssl
openssl rand -base64 32

# Or using Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Add this to your `.env` file:

```env
NOTESNOOK_API_SECRET=your-generated-secret-here
```

## Step 4: Start the Services

Run the startup script:

```bash
./start.sh
```

The script will automatically:
- Validate your configuration
- Select the appropriate Docker Compose files
- Start all required services

## Step 5: Access Your Instance

Once all services are running, you can access:

- **Notesnook Web App**: http://localhost:8888
- **MinIO Console**: http://localhost:9000 (admin/your-password)
- **API Server**: http://localhost:5264
- **Identity Server**: http://localhost:8264
- **SSE Server**: http://localhost:7264
- **Monograph Server**: http://localhost:6264

## Step 6: Create Your First Account

1. Open http://localhost:8888 in your browser
2. Click "Sign Up" to create your first account
3. Verify your email address (check your email)
4. Start using Notesnook!

## Configuration Summary

This setup provides:

- ✅ Self-hosted MinIO for file storage
- ✅ Direct port access (no reverse proxy)
- ✅ All required Notesnook services
- ✅ Web interface for easy access
- ✅ Automatic health monitoring
- ✅ Email verification support

**Note**: You can run Notesnook in API-only mode by setting `USE_WEB_APP=false` in `env/webapp.env` if you prefer to use mobile apps or external clients.

## Next Steps

- For production use with SSL certificates, see [Reverse Proxy Setup](./reverse-proxy/README.md)
- For using external S3 services, see [External S3 Configuration](./external-s3.md)
- For troubleshooting issues, see [Troubleshooting](./troubleshooting.md)

## Service Ports

| Service | Port | Description | Condition |
|---------|------|-------------|-----------|
| Web App | 8888 | Notesnook web interface | `USE_WEB_APP=true` |
| MinIO | 9000 | S3-compatible storage | `SELF_HOST_S3=true` |
| MinIO Console | 9090 | MinIO web interface | `SELF_HOST_S3=true` |
| Sync Server | 5264 | Main API server | Always |
| Identity Server | 8264 | Authentication | Always |
| SSE Server | 7264 | Real-time updates | Always |
| Monograph Server | 6264 | Public sharing | Always |
| MongoDB | 27017 | Database | Always |
