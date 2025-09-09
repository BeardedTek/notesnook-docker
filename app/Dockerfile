# Build Stage
FROM node:20 AS builder

WORKDIR /app

# Install git & cleanup cache
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Clone Notesnook monorepo
RUN git clone --depth=1 https://github.com/streetwriters/notesnook.git .

# Install dependencies (monorepo root)
RUN npm ci

# Build just the web app
RUN npm run build:web

# Production Stage
FROM nginx

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from builder
COPY --from=builder /app/apps/web/build /usr/share/nginx/html

# Optional: custom nginx config for SPA
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]