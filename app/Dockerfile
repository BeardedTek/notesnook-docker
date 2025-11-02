# Build Stage
FROM node:20 AS builder

WORKDIR /app

# Install git & cleanup cache
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Clone Notesnook monorepo
RUN git clone --depth=1 https://github.com/beardedtek/notesnook.git .

# Install dependencies (monorepo root)
RUN npm ci

# Accept build-time environment variables for server URLs
ARG NN_API_HOST
ARG NN_AUTH_HOST
ARG NN_SSE_HOST
ARG NN_MONOGRAPH_HOST
ARG NN_NOTESNOOK_HOST

# Set environment variables for the build process
ENV NN_API_HOST=${NN_API_HOST}
ENV NN_AUTH_HOST=${NN_AUTH_HOST}
ENV NN_SSE_HOST=${NN_SSE_HOST}
ENV NN_MONOGRAPH_HOST=${NN_MONOGRAPH_HOST}
ENV NN_NOTESNOOK_HOST=${NN_NOTESNOOK_HOST}

# Build just the web app
RUN npm run build:web

# Production Stage
FROM nginx

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from builder
COPY --from=builder /app/apps/web/build /usr/share/nginx/html

# Custom nginx config for SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]