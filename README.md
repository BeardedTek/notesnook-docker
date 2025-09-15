# Notesnook Self-Hosted Docker Setup

A complete Docker Compose setup for self-hosting Notesnook.
**Note**: This is an unofficial Docker setup for Notesnook. For official support, please refer to the [Notesnook documentation](https://help.notesnook.com/).

## Services Included

### Required Services

- **MongoDB** - Backend Database
  - Storage for notes and authentication data
- **Notesnook Sync Server** - Notesnook API Sync Server
  - This is the API the notesnook app syncs from
- **Identity Server** - Notesnook Authentication Server
  - This provides authentication for the app
- **SSE Server** - Notesnook Events Server
  - Provides real time updates to clients by pushing data to them, enabling instant synchronization between devices.

### Optional Services

- **React Web App** - Notesnook Web App
  - Not required, but provides a web interface pre-configured with our self hosted servers.
- **MinIO** - S3 Compatible Storage for Attachments Only
  - Required to store attachments locally - Any S3 compatible storage server can be used.
- **Monograph Server** - Monograph Note Publishing Server
  - Required to publish notes externally
- **Autoheal** - Autoheal Service to restart containers on failed health check
  - Not required, but helpful to restart failed services

## Minimum Requirements

### On x86_64 Systems

#### Intel

- Sandy Bridge or later Core processors
- Tiger Lake or later Celeron or Pentium processor

#### AMD

- Bulldozer or later processor

### On ARM64 Systems

ARMv8.2-A or later microarchitecture

### Docker

Docker's convenience script will work on most distributions:

```bash
curl -sSL https://get.docker.com/ | sh
```

For SUSE Linux:

```bash
sudo zypper install docker
sudo systemctl enable docker.service
```

## Quick Start

1. Clone this repository
2. Configure your environment variables in the `env/` directory files
3. Run `./start.sh`

## Documentation

For detailed setup instructions, configuration options, and troubleshooting, see the [Documentation](./docs/README.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.