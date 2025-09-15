# Troubleshooting Guide

This guide covers common issues and solutions when setting up or running Notesnook Docker.

## General Issues

### Services Won't Start

**Problem**: Docker containers fail to start or exit immediately.

**Solutions**:
```bash
# Check container logs
docker-compose logs <service-name>

# Check if ports are already in use
netstat -tulpn | grep :8888

# Restart services
docker-compose down && docker-compose up -d
```

### Environment Variables Not Loading

**Problem**: Configuration changes aren't taking effect.

**Solutions**:
```bash
# Verify environment files exist
ls -la env/

# Check .env file syntax (no spaces around =)
cat .env

# Restart services to reload environment
docker-compose down && docker-compose up -d
```

### Database Connection Issues

**Problem**: Services can't connect to MongoDB.

**Solutions**:
```bash
# Check MongoDB container status
docker-compose ps notesnook-db

# Check MongoDB logs
docker-compose logs notesnook-db

# Verify MongoDB is accepting connections
docker-compose exec notesnook-db mongosh --eval "db.adminCommand('ping')"
```

## S3/MinIO Issues

### MinIO Not Starting

**Problem**: MinIO container fails to start or is inaccessible.

**Solutions**:
```bash
# Check MinIO logs
docker-compose logs notesnook-s3

# Verify MinIO credentials
docker-compose exec notesnook-s3 mc alias list

# Check MinIO health
curl http://localhost:9000/minio/health/live
```

### File Upload Failures

**Problem**: File attachments fail to upload or download.

**Solutions**:
- Verify MinIO bucket exists: `docker-compose exec setup-s3 mc ls minio/`
- Check S3 credentials in `env/s3.env`
- Verify network connectivity between services
- Check MinIO console at http://localhost:9000

### External S3 Connection Issues

**Problem**: Can't connect to external S3 service.

**Solutions**:
- Verify S3 credentials are correct
- Check S3 service URL format
- Ensure bucket exists and has proper permissions
- Test S3 connectivity: `curl -I https://your-s3-endpoint.com`

## Reverse Proxy Issues

### SSL Certificate Problems

**Problem**: SSL certificates not generating or invalid.

**Solutions**:
```bash
# Check DNS resolution
nslookup app.your-domain.com

# Verify ports 80/443 are open
telnet your-domain.com 80
telnet your-domain.com 443

# Check reverse proxy logs
docker-compose logs traefik
docker-compose logs nginx
docker-compose logs caddy
```

### 502 Bad Gateway Errors

**Problem**: Reverse proxy returns 502 errors.

**Solutions**:
- Verify Notesnook services are running: `docker-compose ps`
- Check service health endpoints: `curl http://localhost:5264/health`
- Verify network connectivity between containers
- Check reverse proxy configuration

### CORS Errors

**Problem**: Browser shows CORS errors when accessing services.

**Solutions**:
- Verify all URLs in `env/servers.env` use HTTPS (for reverse proxy)
- Check that domain names match your DNS configuration
- Ensure services are accessible via their configured URLs

## Email Issues

### SMTP Connection Failed

**Problem**: Email verification and password reset emails not sending.

**Solutions**:
```bash
# Test SMTP connection
telnet smtp.your-domain.com 587

# Check SMTP credentials in env/smtp.env
# Verify SMTP server allows authentication
# Test with a simple email client
```

### Email Not Received

**Problem**: Emails are sent but not received.

**Solutions**:
- Check spam/junk folders
- Verify SMTP server logs
- Test with different email providers
- Check email server reputation

## Performance Issues

### Slow Response Times

**Problem**: Services respond slowly or time out.

**Solutions**:
```bash
# Check resource usage
docker stats

# Check container logs for errors
docker-compose logs

# Verify database performance
docker-compose exec notesnook-db mongosh --eval "db.runCommand({serverStatus: 1})"
```

### High Memory Usage

**Problem**: Containers using excessive memory.

**Solutions**:
- Restart services: `docker-compose restart`
- Check for memory leaks in logs
- Consider increasing server RAM
- Monitor with: `docker stats`

## Network Issues

### Container Communication Problems

**Problem**: Services can't communicate with each other.

**Solutions**:
```bash
# Check Docker networks
docker network ls
docker network inspect notesnook

# Test connectivity between containers
docker-compose exec notesnook-server ping identity-server
docker-compose exec notesnook-server ping notesnook-db
```

### Port Access Issues

**Problem**: Can't access services via browser.

**Solutions**:
- Check firewall settings
- Verify port mappings in docker-compose.yml
- Test local access: `curl http://localhost:8888`
- Check if ports are bound to correct interfaces

## Data Issues

### Database Data Loss

**Problem**: Notes or user data is missing.

**Solutions**:
```bash
# Check database volumes
docker volume ls
docker volume inspect notesnook-docker_dbdata

# Verify data persistence
docker-compose exec notesnook-db mongosh --eval "show dbs"
```

### File Storage Issues

**Problem**: Attachments are missing or corrupted.

**Solutions**:
- Check MinIO volume: `docker volume inspect notesnook-docker_s3data`
- Verify file permissions in MinIO console
- Check MinIO logs for errors
- Restore from backup if available

## Log Analysis

### Viewing Logs

```bash
# All services
docker-compose logs

# Specific service
docker-compose logs notesnook-server

# Follow logs in real-time
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100
```

### Common Error Patterns

- **Connection refused**: Service not running or port blocked
- **Permission denied**: File permissions or authentication issues
- **Timeout**: Network connectivity or service overload
- **Out of memory**: Insufficient RAM or memory leak

## Getting Help

### Information to Collect

When seeking help, gather:

1. **Configuration**: Your `.env` file (remove sensitive data)
2. **Logs**: Relevant service logs
3. **System Info**: OS, Docker version, available resources
4. **Steps**: What you were doing when the issue occurred

### Useful Commands

```bash
# System information
docker version
docker-compose version
uname -a
free -h
df -h

# Service status
docker-compose ps
docker-compose logs --tail=50

# Network information
docker network ls
docker network inspect notesnook

# Volume information
docker volume ls
docker volume inspect <volume-name>
```

### Community Support

- Check existing issues in the repository
- Search for similar problems online
- Provide detailed information when reporting issues
- Include relevant logs and configuration (sanitized)