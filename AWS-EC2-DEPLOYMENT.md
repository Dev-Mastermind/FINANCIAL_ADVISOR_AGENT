# Financial Advisor Agent - AWS EC2 Deployment Guide

This guide provides step-by-step instructions for deploying the Financial Advisor Agent application on AWS EC2 using the development environment.

## Prerequisites

- AWS EC2 instance (Ubuntu 20.04+ recommended)
- Domain name (optional)
- API keys for OpenAI, Google OAuth, and HubSpot

## Required API Keys

You'll need the following API keys (replace with your actual values):

### 1. OpenAI API Key
- **Purpose**: AI chat functionality
- **Get from**: https://platform.openai.com/account/api-keys

### 2. Google OAuth Credentials
- **Client ID**: Your Google OAuth Client ID
- **Client Secret**: Your Google OAuth Client Secret
- **Purpose**: Google authentication and Gmail/Calendar integration
- **Get from**: https://console.developers.google.com/

### 3. HubSpot API Key
- **Purpose**: CRM integration
- **Get from**: https://developers.hubspot.com/

## Step-by-Step Deployment

### 1. Connect to Your EC2 Instance

```bash
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### 2. Install Docker and Docker Compose

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again to apply docker group changes
exit
# SSH back in
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

### 3. Clone and Set Up the Project

```bash
# Clone your repository
git clone <your-repository-url>
cd financial_advisor_agent

# Switch to the deployment branch
git checkout deployment/final-clean

# Create environment file from template
cp docker.env.example docker.env

# Edit the environment file with your actual API keys
nano docker.env
```

### 4. Configure Environment Variables

Edit the `docker.env` file with your actual API keys:

```bash
# Development Environment Variables
DATABASE_URL=ecto://postgres:postgres@postgres:5432/financial_advisor_agent_dev

# Application Secrets
SECRET_KEY_BASE=3YnjUOTCI63m06VgQmWPD1orEbISHfjksMP1kj3Jvtypn2kXQD2q6AkMeJz0OR1a
GUARDIAN_SECRET_KEY=mock-guardian-secret-key-for-development-only

# OpenAI API Key
OPENAI_API_KEY=your_actual_openai_api_key_here

# Google OAuth Credentials
GOOGLE_CLIENT_ID=your_actual_google_client_id_here
GOOGLE_CLIENT_SECRET=your_actual_google_client_secret_here

# HubSpot API Key
HUBSPOT_API_KEY=your_actual_hubspot_api_key_here

# Other settings
PORT=4000
MIX_ENV=dev
```

### 5. Deploy the Application

```bash
# Deploy the development environment
docker-compose -f docker-compose.dev.yml up --build -d

# Check if containers are running
docker-compose -f docker-compose.dev.yml ps

# View logs to ensure everything is working
docker-compose -f docker-compose.dev.yml logs app
```

### 6. Configure Security Group

In your AWS EC2 console:
1. Go to **EC2 Dashboard** → **Security Groups**
2. Find your instance's security group
3. Add these inbound rules:
   - **Type**: HTTP, **Port**: 80, **Source**: 0.0.0.0/0
   - **Type**: Custom TCP, **Port**: 4000, **Source**: 0.0.0.0/0
   - **Type**: SSH, **Port**: 22, **Source**: Your IP (for security)

### 7. Update Google OAuth Redirect URIs

In your Google Cloud Console:
1. Go to **APIs & Services** → **Credentials**
2. Edit your OAuth 2.0 Client ID
3. Add your EC2 public IP to authorized redirect URIs:
   - `http://your-ec2-public-ip:4000/auth/google/callback`

### 8. Access Your Application

```bash
# Get your EC2 public IP
curl -s http://169.254.169.254/latest/meta-data/public-ipv4

# Your application will be available at:
http://your-ec2-public-ip:4000
```

## Management Commands

```bash
# View application logs
docker-compose -f docker-compose.dev.yml logs app

# View all logs
docker-compose -f docker-compose.dev.yml logs

# Stop the environment
docker-compose -f docker-compose.dev.yml down

# Restart the environment
docker-compose -f docker-compose.dev.yml up --build -d

# Check container status
docker-compose -f docker-compose.dev.yml ps

# Access container shell (for debugging)
docker-compose -f docker-compose.dev.yml exec app /bin/sh
```

## Quick Deployment Script

Create this script for easy deployment:

```bash
# Create deployment script
cat > deploy-ec2.sh << 'EOF'
#!/bin/bash

echo "🚀 Deploying Financial Advisor Agent on EC2..."

# Stop any existing containers
docker-compose -f docker-compose.dev.yml down

# Build and start services
docker-compose -f docker-compose.dev.yml up --build -d

# Wait for services to start
sleep 10

# Check status
echo "📊 Container Status:"
docker-compose -f docker-compose.dev.yml ps

echo "✅ Deployment complete!"
echo "🌐 Application: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):4000"
EOF

# Make it executable
chmod +x deploy-ec2.sh

# Run deployment
./deploy-ec2.sh
```

## Troubleshooting

```bash
# Check if Docker is running
sudo systemctl status docker

# Restart Docker if needed
sudo systemctl restart docker

# Check available disk space
df -h

# Check memory usage
free -h

# View detailed container logs
docker-compose -f docker-compose.dev.yml logs --tail=50 app

# Rebuild without cache if needed
docker-compose -f docker-compose.dev.yml build --no-cache
docker-compose -f docker-compose.dev.yml up -d
```

## Security Notes

1. **Change default passwords** in production
2. **Use strong secrets** for SECRET_KEY_BASE and GUARDIAN_SECRET_KEY
3. **Enable firewall** and restrict access to necessary ports
4. **Use HTTPS** in production with SSL certificate
5. **Monitor logs** regularly
6. **Never commit API keys** to version control

## Support

If you encounter issues:
1. Check the logs: `docker-compose -f docker-compose.dev.yml logs app`
2. Verify environment variables are set correctly in `docker.env`
3. Ensure all required ports are accessible in security groups
4. Check Google OAuth configuration matches your EC2 IP
