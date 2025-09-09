# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

# Install git and other build dependencies
RUN apk add --no-cache git

# Clone Notesnook monorepo with specific tag/commit for reproducibility
ARG NOTESNOOK_VERSION=latest
RUN git clone --depth=1 --branch ${NOTESNOOK_VERSION} https://github.com/streetwriters/notesnook.git .

# Install dependencies (monorepo root)
RUN npm ci --only=production --no-audit --no-fund

# Build just the web app
RUN npm run build:web

# Production Stage
FROM nginx:1.25-alpine

# Create non-root user for security
RUN addgroup -g 1001 -S nginx && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Remove default nginx site and create necessary directories
RUN rm -rf /usr/share/nginx/html/* && \
    mkdir -p /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /usr/share/nginx/html

# Copy build output from builder
COPY --from=builder /app/apps/web/build /usr/share/nginx/html

# Copy custom nginx configuration for SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Security: Run as non-root user
USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]