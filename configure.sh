#!/bin/bash

# Notesnook Docker Configuration Script
# Interactive setup wizard for configuring Notesnook self-hosted instance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to prompt for input with validation
prompt_input() {
    local prompt="$1"
    local var_name="$2"
    local validation_func="$3"
    local default="$4"
    
    while true; do
        if [ -n "$default" ]; then
            read -p "$prompt [$default]: " input
            input=${input:-$default}
        else
            read -p "$prompt: " input
        fi
        
        if [ -z "$input" ]; then
            print_error "This field is required. Please enter a value."
            continue
        fi
        
        if [ -n "$validation_func" ] && ! $validation_func "$input"; then
            continue
        fi
        
        eval "$var_name='$input'"
        break
    done
}

# Validation functions
validate_domain() {
    if [[ $1 =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?(\.[a-zA-Z]{2,})+$ ]]; then
        return 0
    else
        print_error "Invalid domain format. Please enter a valid domain (e.g., example.com)"
        return 1
    fi
}

validate_email() {
    if [[ $1 =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        print_error "Invalid email format. Please enter a valid email address."
        return 1
    fi
}

validate_port() {
    if [[ $1 =~ ^[0-9]+$ ]] && [ $1 -ge 1 ] && [ $1 -le 65535 ]; then
        return 0
    else
        print_error "Invalid port number. Please enter a number between 1 and 65535."
        return 1
    fi
}

validate_secret() {
    if [ ${#1} -ge 32 ]; then
        return 0
    else
        print_error "API secret must be at least 32 characters long."
        return 1
    fi
}

validate_password() {
    if [ ${#1} -ge 8 ]; then
        return 0
    else
        print_error "Password must be at least 8 characters long."
        return 1
    fi
}

# Function to generate a secure API secret
generate_api_secret() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 32
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c "import secrets; print(secrets.token_urlsafe(32))"
    else
        # Fallback to /dev/urandom
        head -c 32 /dev/urandom | base64
    fi
}

# Function to check if port is available
check_port() {
    local port=$1
    if command -v netstat >/dev/null 2>&1; then
        ! netstat -tuln | grep -q ":$port "
    elif command -v ss >/dev/null 2>&1; then
        ! ss -tuln | grep -q ":$port "
    else
        # If we can't check, assume it's available
        return 0
    fi
}

# Main configuration function
configure_notesnook() {
    print_info "Welcome to the Notesnook Docker Configuration Wizard!"
    print_info "This script will help you configure your Notesnook self-hosted instance."
    echo
    
    # Create env directory if it doesn't exist
    mkdir -p env
    
    print_info "Step 1: Basic Configuration"
    echo "=================================="
    
    # Instance name
    prompt_input "Enter instance name" INSTANCE_NAME "" "my-notesnook-instance"
    
    # API Secret
    print_info "Generating a secure API secret..."
    GENERATED_SECRET=$(generate_api_secret)
    prompt_input "Enter API secret (32+ characters)" NOTESNOOK_API_SECRET "validate_secret" "$GENERATED_SECRET"
    
    # Disable signups
    while true; do
        read -p "Disable new user signups? (y/n) [n]: " disable_signups
        disable_signups=${disable_signups:-n}
        case $disable_signups in
            [Yy]* ) DISABLE_SIGNUPS=true; break;;
            [Nn]* ) DISABLE_SIGNUPS=false; break;;
            * ) print_error "Please answer yes (y) or no (n).";;
        esac
    done
    
    echo
    print_info "Step 2: Domain Configuration"
    echo "================================"
    
    # Base domain
    prompt_input "Enter your base domain" BASE_DOMAIN "validate_domain" "notes.example.com"
    
    echo
    print_info "Step 3: SMTP Configuration"
    echo "=============================="
    print_warning "SMTP is required for email verification and password resets."
    
    # SMTP configuration
    prompt_input "Enter SMTP username (usually your email)" SMTP_USERNAME "validate_email"
    prompt_input "Enter SMTP password" SMTP_PASSWORD "validate_password"
    prompt_input "Enter SMTP host" SMTP_HOST "" "smtp.gmail.com"
    prompt_input "Enter SMTP port" SMTP_PORT "validate_port" "587"
    
    echo
    print_info "Step 4: S3 Configuration"
    echo "==========================="
    
    # S3 configuration
    while true; do
        read -p "Use self-hosted MinIO for file storage? (y/n) [y]: " use_minio
        use_minio=${use_minio:-y}
        case $use_minio in
            [Yy]* ) 
                SELF_HOST_S3=true
                prompt_input "Enter MinIO root username" MINIO_ROOT_USER "" "admin"
                prompt_input "Enter MinIO root password" MINIO_ROOT_PASSWORD "validate_password"
                break;;
            [Nn]* ) 
                SELF_HOST_S3=false
                print_info "External S3 configuration:"
                prompt_input "Enter S3 Access Key ID" S3_ACCESS_KEY_ID
                prompt_input "Enter S3 Secret Access Key" S3_ACCESS_KEY
                prompt_input "Enter S3 Service URL" S3_SERVICE_URL "" "https://s3.amazonaws.com"
                prompt_input "Enter S3 Region" S3_REGION "" "us-east-1"
                prompt_input "Enter S3 Bucket Name" S3_BUCKET_NAME
                break;;
            * ) print_error "Please answer yes (y) or no (n).";;
        esac
    done
    
    echo
    print_info "Step 5: Web App Configuration"
    echo "================================"
    
    # Web app configuration
    while true; do
        read -p "Enable the Notesnook web interface? (y/n) [y]: " enable_webapp
        enable_webapp=${enable_webapp:-y}
        case $enable_webapp in
            [Yy]* ) USE_WEB_APP=true; break;;
            [Nn]* ) USE_WEB_APP=false; break;;
            * ) print_error "Please answer yes (y) or no (n).";;
        esac
    done
    
    echo
    print_info "Step 6: Reverse Proxy Configuration"
    echo "======================================"
    
    # Reverse proxy configuration
    while true; do
        read -p "Use Traefik reverse proxy with automatic SSL? (y/n) [n]: " use_traefik
        use_traefik=${use_traefik:-n}
        case $use_traefik in
            [Yy]* ) USE_TRAEFIK=true; break;;
            [Nn]* ) USE_TRAEFIK=false; break;;
            * ) print_error "Please answer yes (y) or no (n).";;
        esac
    done
    
    echo
    print_info "Step 7: Optional Configuration"
    echo "================================="
    
    # Twilio configuration (optional)
    while true; do
        read -p "Configure Twilio for SMS 2FA? (y/n) [n]: " use_twilio
        use_twilio=${use_twilio:-n}
        case $use_twilio in
            [Yy]* ) 
                prompt_input "Enter Twilio Account SID" TWILIO_ACCOUNT_SID
                prompt_input "Enter Twilio Auth Token" TWILIO_AUTH_TOKEN
                prompt_input "Enter Twilio Service SID" TWILIO_SERVICE_SID
                break;;
            [Nn]* ) 
                TWILIO_ACCOUNT_SID=""
                TWILIO_AUTH_TOKEN=""
                TWILIO_SERVICE_SID=""
                break;;
            * ) print_error "Please answer yes (y) or no (n).";;
        esac
    done
    
    echo
    print_info "Step 8: Configuration Summary"
    echo "==============================="
    
    echo "Instance Name: $INSTANCE_NAME"
    echo "Base Domain: $BASE_DOMAIN"
    echo "API Secret: ${NOTESNOOK_API_SECRET:0:8}..."
    echo "Disable Signups: $DISABLE_SIGNUPS"
    echo "SMTP Host: $SMTP_HOST:$SMTP_PORT"
    echo "Self-hosted S3: $SELF_HOST_S3"
    echo "Web App: $USE_WEB_APP"
    echo "Traefik: $USE_TRAEFIK"
    if [ "$use_twilio" = "y" ]; then
        echo "Twilio: Configured"
    else
        echo "Twilio: Not configured"
    fi
    
    echo
    while true; do
        read -p "Save this configuration? (y/n): " save_config
        case $save_config in
            [Yy]* ) break;;
            [Nn]* ) 
                print_info "Configuration cancelled."
                exit 0;;
            * ) print_error "Please answer yes (y) or no (n).";;
        esac
    done
    
    # Save configuration to env files
    save_configuration
    
    print_success "Configuration saved successfully!"
    print_info "You can now run './start.sh' to start your Notesnook instance."
}

# Function to save configuration to .env file
save_configuration() {
    print_info "Saving configuration to .env file..."
    
    cat > .env << EOF
# Notesnook Docker Environment Configuration
# Generated by configure.sh on $(date)

# =============================================================================
# BASIC CONFIGURATION
# =============================================================================

# Description: Name of your self hosted instance. Used in the client apps for identification purposes
# Required: yes
# Example: notesnook-instance-sg
INSTANCE_NAME=$INSTANCE_NAME

# Description: This secret is used for generating, validating, and introspecting auth tokens. It must be a randomly generated token (preferably >32 characters).
# Required: yes
NOTESNOOK_API_SECRET=$NOTESNOOK_API_SECRET

# Description: Use this flag to disable creation of new accounts on your instance (i.e. in case it is exposed to the Internet).
# Required: yes
# Possible values: true/false
DISABLE_SIGNUPS=$DISABLE_SIGNUPS

# =============================================================================
# DOMAIN CONFIGURATION
# =============================================================================

# Description: Your base domain for all services
# Required: yes
# Example: notes.example.com
BASE_DOMAIN=$BASE_DOMAIN

# Generated domain variables (automatically derived from BASE_DOMAIN)
NOTESNOOK_SYNC_DOMAIN=notes.\${BASE_DOMAIN}
NOTESNOOK_APP_DOMAIN=app.\${BASE_DOMAIN}
NOTESNOOK_MONOGRAPH_DOMAIN=monograph.\${BASE_DOMAIN}
NOTESNOOK_AUTH_DOMAIN=auth.\${BASE_DOMAIN}
NOTESNOOK_SSE_DOMAIN=sse.\${BASE_DOMAIN}
NOTESNOOK_S3_DOMAIN=s3.\${BASE_DOMAIN}
NOTESNOOK_S3_APP_DOMAIN=app.s3.\${BASE_DOMAIN}

# =============================================================================
# SERVER CONFIGURATION
# =============================================================================

# Description: This is the public URL for the Sync server. It'll be used by the Notesnook clients for making API requests.
# Required: yes
# Example: https://sync.notesnook.com
NOTESNOOK_SYNC_PUBLIC_URL=https://\${NOTESNOOK_SYNC_DOMAIN}

# Description: Add the origins for which you want to allow CORS. Leave it empty to allow all origins to access your server. If you want to allow multiple origins, seperate each origin with a comma.
# Required: no
# Example: https://app.notesnook.com,http://localhost:3000
NOTESNOOK_CORS_ORIGINS=

# Description: This is the public URL for the web app, and is used by the backend for creating redirect URLs (e.g. after email confirmation etc).
# Note: the URL has no slashes at the end
# Required: yes
# Example: https://app.notesnook.com
NOTESNOOK_APP_PUBLIC_URL=https://\${NOTESNOOK_APP_DOMAIN}

# Description: This is the public URL for the monograph frontend.
# Required: yes
# Example: https://monogr.ph
MONOGRAPH_PUBLIC_URL=https://\${NOTESNOOK_MONOGRAPH_DOMAIN}

# Description: This is the public URL for the Authentication server. Used for generating email confirmation & password reset URLs.
# Required: yes
# Example: https://auth.streetwriters.co
AUTH_SERVER_PUBLIC_URL=https://\${NOTESNOOK_AUTH_DOMAIN}

# Description: This is the public URL for the S3 attachments server (minio). It'll be used by the Notesnook clients for uploading/downloading attachments.
# Required: yes
# Example: https://attachments.notesnook.com
ATTACHMENTS_SERVER_PUBLIC_URL=https://\${NOTESNOOK_S3_DOMAIN}

# Description: This is the public URL for the SSE server. It'll be used by the Notesnook clients for real-time sync.
# Required: Only if using Traefik
# Example: https://sse.notesnook.com
SSE_SERVER_PUBLIC_URL=https://\${NOTESNOOK_SSE_DOMAIN}

# =============================================================================
# SMTP CONFIGURATION
# =============================================================================

# SMTP Configuration is required for sending emails for password reset, 2FA emails etc. You can get SMTP settings from your email provider.

# Description: Username for the SMTP connection (most time it is the email address of your account). Check your email provider's documentation to get the appropriate value.
# Required: yes
SMTP_USERNAME=$SMTP_USERNAME

# Description: Password for the SMTP connection. Check your email provider's documentation to get the appropriate value.
# Required: yes
SMTP_PASSWORD=$SMTP_PASSWORD

# Description: Host on which the the SMTP connection is running. Check your email provider's documentation to get the appropriate value.
# Required: yes
# Example: smtp.gmail.com
SMTP_HOST=$SMTP_HOST

# Description: Port on which the the SMTP connection is running. Check your email provider's documentation to get the appropriate value.
# Required: yes
# Example: 465
SMTP_PORT=$SMTP_PORT

# =============================================================================
# TWILIO CONFIGURATION (OPTIONAL)
# =============================================================================

# Description: Twilio account SID is required for sending SMS with 2FA codes. Learn more here: https://help.twilio.com/articles/14726256820123-What-is-a-Twilio-Account-SID-and-where-can-I-find-it-
# Required: no
TWILIO_ACCOUNT_SID=$TWILIO_ACCOUNT_SID

# Description: Twilio account auth is required for sending SMS with 2FA codes. Learn more here: https://help.twilio.com/articles/223136027-Auth-Tokens-and-How-to-Change-Them
# Required: no
TWILIO_AUTH_TOKEN=$TWILIO_AUTH_TOKEN

# Description: The unique string that we created to identify the Service resource.
# Required: no
# Example: VAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
TWILIO_SERVICE_SID=$TWILIO_SERVICE_SID

# =============================================================================
# S3 CONFIGURATION
# =============================================================================

# Description: Set to 'true' to use self-hosted MinIO. When 'false' or unset, external S3 will be used.
# Required: no
# Possible values: true/false
SELF_HOST_S3=$SELF_HOST_S3

# -----------------------------------------------------------------------------
# Self-hosted MinIO Configuration (used when SELF_HOST_S3=true)
# -----------------------------------------------------------------------------

# Description: Custom username for the root Minio account. Minio is used for storing your attachments. This must be greater than 3 characters in length.
# Required: no (when using self-hosted MinIO)
MINIO_ROOT_USER=$MINIO_ROOT_USER

# Description: Custom password for the root Minio account. Minio is used for storing your attachments. This must be greater than 8 characters in length.
# Required: no (when using self-hosted MinIO)
MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD

# -----------------------------------------------------------------------------
# External S3 Configuration (used when SELF_HOST_S3=false)
# -----------------------------------------------------------------------------

# Description: AWS S3 Access Key ID for authentication with external S3 service
# Required: yes (when using external S3)
S3_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID

# Description: AWS S3 Secret Access Key for authentication with external S3 service
# Required: yes (when using external S3)
S3_ACCESS_KEY=$S3_ACCESS_KEY

# Description: The S3 service endpoint URL (e.g., https://s3.amazonaws.com or MinIO URL)
# Required: yes (when using external S3)
# Example: https://s3.amazonaws.com or https://minio.example.com
S3_SERVICE_URL=$S3_SERVICE_URL

# Description: AWS S3 region (e.g., us-east-1)
# Required: yes (when using external S3)
# Example: us-east-1
S3_REGION=$S3_REGION

# Description: The main S3 bucket name for storing attachments
# Required: yes (when using external S3)
# Example: notesnook-attachments
S3_BUCKET_NAME=$S3_BUCKET_NAME

# Description: Internal bucket name (used when running in Dockerized environments with external S3)
# Required: no (defaults to S3_BUCKET_NAME)
# Example: notesnook-attachments
S3_INTERNAL_BUCKET_NAME=

# Description: Internal S3 service URL (used for Docker internal networking with external S3)
# Required: no (defaults to S3_SERVICE_URL)
# Example: https://internal-s3.example.com
S3_INTERNAL_SERVICE_URL=

# =============================================================================
# WEB APP CONFIGURATION
# =============================================================================

# Description: Set to 'true' to enable the Notesnook web app. When 'false' or unset, the web app will not be deployed.
# Required: no
# Possible values: true/false
USE_WEB_APP=$USE_WEB_APP

# Description: Override the default API server URL for the web app. If not set, will use the default Notesnook API.
# Required: no
# Example: https://sync.notesnook.com
NN_API_HOST=\${NOTESNOOK_SYNC_PUBLIC_URL}

# Description: Override the default authentication server URL for the web app. If not set, will use the default Notesnook auth server.
# Required: no
# Example: https://auth.notesnook.com
NN_AUTH_HOST=\${AUTH_SERVER_PUBLIC_URL}

# Description: Override the default SSE server URL for the web app. If not set, will use the default Notesnook SSE server.
# Required: no
# Example: https://sse.notesnook.com
NN_SSE_HOST=\${SSE_SERVER_PUBLIC_URL}

# Description: Override the default monograph server URL for the web app. If not set, will use the default Notesnook monograph server.
# Required: no
# Example: https://monogr.ph
NN_MONOGRAPH_HOST=\${MONOGRAPH_PUBLIC_URL}

# =============================================================================
# TRAEFIK CONFIGURATION
# =============================================================================

# Description: Set to 'true' to enable Traefik reverse proxy with automatic SSL certificates. When 'false' or unset, services will be accessible via direct port mapping.
# Required: no
# Possible values: true/false
USE_TRAEFIK=$USE_TRAEFIK
EOF
}

# Main execution
main() {
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found. Please run this script from the notesnook-docker directory."
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    configure_notesnook
}

# Run main function
main "$@"
