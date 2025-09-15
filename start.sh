#!/bin/bash

# Notesnook Docker Startup Script
# Automatically selects the correct Docker Compose configuration based on environment variables

set -e

# Load environment variables
# Load .env file if it exists
if [ -f .env ]; then
    echo "Loading environment from .env"
    # Remove carriage returns and export variables
    while IFS= read -r line; do
        line=$(echo "$line" | tr -d '\r')
        if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && [[ ! "$line" =~ ^# ]]; then
            export "$line"
        fi
    done < .env
fi

# Load all env/* files
if [ -d env ]; then
    for env_file in env/*.env; do
        if [ -f "$env_file" ]; then
            echo "Loading environment from $env_file"
            # Remove carriage returns and export variables
            while IFS= read -r line; do
                line=$(echo "$line" | tr -d '\r')
                if [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && [[ ! "$line" =~ ^# ]]; then
                    export "$line"
                fi
            done < "$env_file"
        fi
    done
fi

echo "Starting Notesnook Docker setup..."

# Show current configuration
echo "Configuration loaded:"
echo "  SELF_HOST_S3: ${SELF_HOST_S3:-not set}"
echo "  USE_WEB_APP: ${USE_WEB_APP:-not set}"
echo "  USE_TRAEFIK: ${USE_TRAEFIK:-not set}"

# Validation function
validate_config() {
    echo "Validating configuration..."
    
    # List of required environment variables
    required_vars=(
        "INSTANCE_NAME"
        "NOTESNOOK_API_SECRET"
        "DISABLE_SIGNUPS"
        "SMTP_USERNAME"
        "SMTP_PASSWORD"
        "SMTP_HOST"
        "SMTP_PORT"
        "AUTH_SERVER_PUBLIC_URL"
        "NOTESNOOK_APP_PUBLIC_URL"
        "MONOGRAPH_PUBLIC_URL"
        "ATTACHMENTS_SERVER_PUBLIC_URL"
    )

    # Check S3 configuration based on SELF_HOST_S3 setting
    if [ "${SELF_HOST_S3}" = "true" ]; then
        echo "Self-hosted MinIO mode enabled - MinIO will be deployed locally."
    else
        echo "External S3 mode enabled - checking external S3 configuration..."
        external_s3_vars=(
            "S3_ACCESS_KEY_ID"
            "S3_ACCESS_KEY"
            "S3_SERVICE_URL"
            "S3_REGION"
            "S3_BUCKET_NAME"
        )
        
        for var in "${external_s3_vars[@]}"; do
            if [ -z "${!var}" ]; then
                echo "Error: Required external S3 environment variable $var is not set."
                exit 1
            fi
        done
        
        echo "External S3 configuration validated."
    fi

    # Check Traefik configuration if enabled
    if [ "${USE_TRAEFIK}" = "true" ]; then
        echo "Traefik mode enabled - checking Traefik configuration..."
        traefik_vars=(
            "NOTESNOOK_SSE_DOMAIN"
        )
        
        for var in "${traefik_vars[@]}"; do
            if [ -z "${!var}" ]; then
                echo "Error: Required Traefik environment variable $var is not set."
                exit 1
            fi
        done
        
        echo "Traefik configuration validated."
    else
        echo "Direct port mode enabled - services will be accessible via direct port mapping."
    fi

    # Check each required environment variable
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "Error: Required environment variable $var is not set."
            exit 1
        fi
    done

    echo "All required environment variables are set."
}

# Run validation
validate_config

# Build compose command based on configuration
COMPOSE_FILES="docker-compose.yml"

# Check if self-hosted S3 is enabled
if [ "${SELF_HOST_S3}" = "true" ]; then
    echo "Self-hosted MinIO mode detected - using local MinIO configuration"
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.s3.yml"
    
    # Add S3 Traefik configuration if Traefik is also enabled
    if [ "${USE_TRAEFIK}" = "true" ]; then
        COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.s3.traefik.yml"
    fi
else
    echo "External S3 mode detected - using external S3 configuration"
fi

# Check if web app is enabled
if [ "${USE_WEB_APP}" = "true" ]; then
    echo "Web app mode detected - including Notesnook web interface"
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.webapp.yml"
else
    echo "API-only mode detected - web app will not be deployed"
fi

# Check if Traefik is enabled
if [ "${USE_TRAEFIK}" = "true" ]; then
    echo "Traefik mode detected - using Traefik reverse proxy configuration"
    COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.traefik.yml"
else
    echo "Direct port mode detected - services will be accessible via direct port mapping"
fi

# Start services with the appropriate configuration
echo "Starting services with: $COMPOSE_FILES"
docker-compose $COMPOSE_FILES up "$@"
