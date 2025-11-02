# Notesnook Self-Hosted Docker Setup

A complete Docker Compose setup for self-hosting Notesnook with all required services including the React web client.

**Note**: This is an unofficial Docker setup for Notesnook. For official support, please refer to the [Notesnook documentation](https://help.notesnook.com/).

## 🏗️ Architecture

This setup includes the following services:

- **MongoDB** - Database for user data and notes
- **MinIO** - S3-compatible storage for file attachments
- **Identity Server** - Authentication and user management
- **Notesnook Sync Server** - Main API server for note synchronization
- **SSE Server** - Real-time updates via Server-Sent Events
- **Monograph Server** - Public note sharing functionality
- **React Web App** - Self-hosted web client
- **Autoheal** - Automatic container health monitoring

## 📋 Prerequisites

- Docker and Docker Compose installed
- Domain name with DNS control
- SMTP server for email notifications
- Basic understanding of Docker and reverse proxy setup

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/beardedtek/notesnook-docker
cd notesnook-docker
```

### 2. Environment Configuration

Copy the example environment file and configure it:

```bash
cp env-example .env
```

Edit `.env` with your specific configuration:

```env
# Required: Your domain
BASE_DOMAIN=your-domain.com

# Required: Instance name
INSTANCE_NAME=my-notesnook-instance

# Required: Generate a secure API secret (32+ characters)
NOTESNOOK_API_SECRET=your-secure-api-secret-here

# Required: SMTP configuration
SMTP_USERNAME=your-email@domain.com
SMTP_PASSWORD=your-smtp-password
SMTP_HOST=smtp.your-domain.com
SMTP_PORT=587

# Optional: MinIO credentials
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=your-secure-password
```

### 3. Deploy

```bash
# Build the app container
docker compose build

# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

## 🔧 Configuration Details

### Environment Variables

#### Core Configuration

- `BASE_DOMAIN` - Your domain name (e.g., `example.com`)
- `INSTANCE_NAME` - Unique identifier for your instance
- `NOTESNOOK_API_SECRET` - Secure random token for API authentication
- `DISABLE_SIGNUPS` - Set to `true` to disable new user registration

#### SMTP Configuration

Required for email notifications (password reset, 2FA, etc.):

- `SMTP_USERNAME` - Your SMTP username (usually your email)
- `SMTP_PASSWORD` - Your SMTP password
- `SMTP_HOST` - SMTP server hostname
- `SMTP_PORT` - SMTP server port (usually 587 or 465)

#### Public URLs

Automatically generated based on your `BASE_DOMAIN`:

- `NOTESNOOK_SYNC_PUBLIC_URL` - Main sync server
- `NOTESNOOK_APP_PUBLIC_URL` - Web application
- `AUTH_SERVER_PUBLIC_URL` - Authentication server
- `SSE_SERVER_PUBLIC_URL` - Real-time sync server
- `MONOGRAPH_PUBLIC_URL` - Public sharing server
- `ATTACHMENTS_SERVER_PUBLIC_URL` - File storage server

#### React Web Client

The web app is automatically configured to connect to your self-hosted services using the public URLs defined above. The following environment variables can be used to override the default server URLs:

- `NN_API_HOST` - Override the default API server URL (defaults to `NOTESNOOK_SYNC_PUBLIC_URL`)
- `NN_AUTH_HOST` - Override the default authentication server URL (defaults to `AUTH_SERVER_PUBLIC_URL`)
- `NN_SSE_HOST` - Override the default SSE server URL (defaults to `SSE_SERVER_PUBLIC_URL`)
- `NN_MONOGRAPH_HOST` - Override the default monograph server URL (defaults to `MONOGRAPH_PUBLIC_URL`)
- `NN_NOTESNOOK_HOST` - Override the default monograph server URL (defaults to `NOTESNOOK_APP_PUBLIC_URL`)

**Note**: These variables are optional and will automatically use your self-hosted service URLs if not specified.

### Service Ports

| Service | Internal Port | External Port | Description |
|---------|---------------|---------------|-------------|
| Web App | 80 | 8888 | React web client |
| Sync Server | 5264 | 5264 | Main API server |
| Identity Server | 8264 | 8264 | Authentication |
| SSE Server | 7264 | 7264 | Real-time updates |
| Monograph Server | 3000 | 6264 | Public sharing |
| MinIO API | 9000 | 9000 | File storage API |
| MinIO Console | 9090 | 9090 | File storage UI |
| MongoDB | 27017 | - | Database (internal only) |

## Reverse Proxy Setup

### Traefik

To use Traefik move docker-compose.traefik.yml to docker-compose.override.yml:

``` bash
mv docker-compose.traefik.yml docker-compose.override.yml
```

### Nginx

To use Nginx please use [https://wiki.steph.click/books/containered-apps/page/notesnook-sync-server-local-storage](https://wiki.steph.click/books/containered-apps/page/notesnook-sync-server-local-storage) as a reference.
