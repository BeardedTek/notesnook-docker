# External S3 Service Configuration

This guide explains how to configure Notesnook to use an external S3-compatible service instead of the self-hosted MinIO.

## Supported S3 Services

You can use any S3-compatible service, including:

- Amazon S3
- Google Cloud Storage
- Azure Blob Storage
- DigitalOcean Spaces
- MinIO (self-hosted or cloud)
- Backblaze B2
- Any other S3-compatible service

## Configuration Steps

### Step 1: Set S3 Configuration

Edit `env/s3.env`:

```env
SELF_HOST_S3=false
```

### Step 2: Configure External S3 Credentials

Add your S3 service credentials to `env/s3.env`:

```env
# S3 Service Credentials
S3_ACCESS_KEY_ID=your-access-key-id
S3_ACCESS_KEY=your-secret-access-key

# S3 Service Endpoint
S3_SERVICE_URL=https://s3.amazonaws.com
S3_REGION=us-east-1

# S3 Bucket Configuration
S3_BUCKET_NAME=notesnook-attachments

# Optional: Internal URLs (for Docker networking)
S3_INTERNAL_SERVICE_URL=https://s3.amazonaws.com
S3_INTERNAL_BUCKET_NAME=notesnook-attachments
```

### Step 3: Create S3 Bucket

Create a bucket in your S3 service with the name specified in `S3_BUCKET_NAME`. Ensure the bucket allows:

- Read access for attachments
- Write access for new uploads
- Appropriate CORS settings if needed

### Step 4: Configure Domain Settings

Update `env/domain.env` with your domain:

```env
BASE_DOMAIN=your-domain.com
```

Update `env/servers.env` with your attachment server URL:

```env
ATTACHMENTS_SERVER_PUBLIC_URL=https://your-s3-domain.com
```

## Service-Specific Examples

### Amazon S3

```env
S3_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
S3_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
S3_SERVICE_URL=https://s3.amazonaws.com
S3_REGION=us-east-1
S3_BUCKET_NAME=my-notesnook-attachments
```

### Google Cloud Storage

```env
S3_ACCESS_KEY_ID=your-gcs-access-key
S3_ACCESS_KEY=your-gcs-secret-key
S3_SERVICE_URL=https://storage.googleapis.com
S3_REGION=us-central1
S3_BUCKET_NAME=my-notesnook-attachments
```

### DigitalOcean Spaces

```env
S3_ACCESS_KEY_ID=your-spaces-access-key
S3_ACCESS_KEY=your-spaces-secret-key
S3_SERVICE_URL=https://nyc3.digitaloceanspaces.com
S3_REGION=nyc3
S3_BUCKET_NAME=my-notesnook-attachments
```

### MinIO (External)

```env
S3_ACCESS_KEY_ID=minioadmin
S3_ACCESS_KEY=minioadmin
S3_SERVICE_URL=https://minio.your-domain.com
S3_REGION=us-east-1
S3_BUCKET_NAME=attachments
```

## Start the Services

Run the startup script:

```bash
./start.sh
```

The script will:
- Skip MinIO services (since `SELF_HOST_S3=false`)
- Configure Notesnook to use your external S3 service
- Start all other required services

## Verification

1. Access the Notesnook web app
2. Create a test account
3. Upload a file attachment
4. Verify the file appears in your S3 bucket

## Troubleshooting

### Common Issues

**403 Forbidden Errors**: Check your S3 credentials and bucket permissions

**Connection Timeout**: Verify your S3 service URL and network connectivity

**CORS Errors**: Configure CORS settings on your S3 bucket if accessing from web browsers

### S3 Bucket Policy Example

For AWS S3, ensure your bucket policy allows the necessary operations:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::YOUR-ACCOUNT-ID:user/YOUR-IAM-USER"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name",
                "arn:aws:s3:::your-bucket-name/*"
            ]
        }
    ]
}
```

## Benefits of External S3

- **Scalability**: No storage limits on your server
- **Reliability**: Managed by cloud providers
- **Backup**: Automatic redundancy and backup
- **Performance**: Global CDN distribution
- **Cost**: Pay only for what you use

## Security Considerations

- Use IAM roles/policies to limit S3 access
- Enable S3 bucket versioning for data protection
- Consider S3 bucket encryption
- Regularly rotate access keys
- Monitor S3 access logs
