# Financial Advisor Platform - Deployment Guide

## Overview

This guide covers deploying the Financial Advisor Platform to various cloud providers and environments, including production-ready configurations, security considerations, and monitoring setup.

## Prerequisites

1. **Source Code Repository** - Code pushed to version control (GitHub, GitLab, etc.)
2. **Environment Configuration** - All production environment variables configured
3. **Database Setup** - PostgreSQL database with vector search capabilities
4. **Domain Configuration** - SSL certificates and domain setup
5. **Service Integrations** - OAuth and API configurations

## Environment Variables

### Required Production Variables

```bash
# Database Configuration
DATABASE_URL=postgresql://user:password@host:port/database

# Phoenix Framework
SECRET_KEY_BASE=your-production-secret-key-base
PHX_HOST=your-domain.com
PORT=4000
MIX_ENV=prod

# OpenAI Integration
OPENAI_API_KEY=sk-proj-your-production-openai-key

# Google OAuth Integration
GOOGLE_CLIENT_ID=your-production-google-client-id
GOOGLE_CLIENT_SECRET=your-production-google-client-secret

# HubSpot CRM Integration
HUBSPOT_CLIENT_ID=your-production-hubspot-client-id
HUBSPOT_CLIENT_SECRET=your-production-hubspot-client-secret
HUBSPOT_REDIRECT_URI=https://your-domain.com/hubspot/callback

# Security Configuration
GUARDIAN_SECRET_KEY=your-production-guardian-secret-key
```

### Optional Configuration

```bash
# Monitoring and Analytics
SENTRY_DSN=your-sentry-dsn
ANALYTICS_ID=your-analytics-id

# Email Configuration
SMTP_HOST=smtp.your-provider.com
SMTP_USERNAME=your-smtp-username
SMTP_PASSWORD=your-smtp-password

# Redis (for caching and sessions)
REDIS_URL=redis://user:password@host:port/database
```

## Deployment Options

### 1. Docker Deployment (Recommended)

#### Docker Compose Production

```bash
# Clone repository
git clone <repository-url>
cd financial-advisor-agent

# Configure environment
cp .env.example .env
# Edit .env with production values

# Deploy with Docker Compose
docker-compose -f docker-compose.yml up -d

# Check status
docker-compose ps
docker-compose logs -f
```

#### Docker Swarm Deployment

```bash
# Initialize Docker Swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml financial-advisor

# Check services
docker service ls
```

### 2. Cloud Platform Deployment

#### Fly.io Deployment

1. **Install Fly CLI:**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login and Configure:**
   ```bash
   fly auth login
   fly launch
   ```

3. **Set Environment Variables:**
   ```bash
   fly secrets set OPENAI_API_KEY=your-key
   fly secrets set GOOGLE_CLIENT_ID=your-client-id
   fly secrets set GOOGLE_CLIENT_SECRET=your-client-secret
   fly secrets set HUBSPOT_API_KEY=your-api-key
   fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
   ```

4. **Deploy:**
   ```bash
   fly deploy
   ```

#### Railway Deployment

1. **Connect Repository:**
   - Connect your GitHub repository to Railway
   - Configure build settings for Elixir/Phoenix

2. **Set Environment Variables:**
   - Add all required environment variables in Railway dashboard
   - Configure database connection

3. **Deploy:**
   - Railway automatically deploys on git push
   - Monitor deployment in Railway dashboard

#### Render Deployment

1. **Create Web Service:**
   - Connect GitHub repository
   - Select Elixir buildpack
   - Configure build and start commands

2. **Environment Configuration:**
   ```bash
   Build Command: mix deps.get && mix assets.deploy
   Start Command: mix phx.server
   ```

3. **Database Setup:**
   - Create PostgreSQL database
   - Configure connection string
   - Run migrations automatically

### 3. VPS/Server Deployment

#### Ubuntu/Debian Server

1. **Server Setup:**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install dependencies
   sudo apt install -y postgresql postgresql-contrib nginx certbot
   
   # Install Elixir
   wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
   sudo dpkg -i erlang-solutions_2.0_all.deb
   sudo apt update
   sudo apt install -y elixir
   ```

2. **Application Deployment:**
   ```bash
   # Clone repository
   git clone <repository-url>
   cd financial-advisor-agent
   
   # Install dependencies
   mix deps.get
   mix assets.deploy
   
   # Database setup
   mix ecto.create
   mix ecto.migrate
   
   # Start application
   mix phx.server
   ```

3. **Nginx Configuration:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:4000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

4. **SSL Certificate:**
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

## Database Setup

### PostgreSQL with Vector Support

1. **Install pgvector Extension:**
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

2. **Database Configuration:**
   ```bash
   # Production database setup
   mix ecto.create
   mix ecto.migrate
   ```

3. **Performance Optimization:**
   ```sql
   -- Create indexes for better performance
   CREATE INDEX CONCURRENTLY idx_agent_tasks_user_id ON agent_tasks(user_id);
   CREATE INDEX CONCURRENTLY idx_integrations_user_id ON integrations(user_id);
   CREATE INDEX CONCURRENTLY idx_rag_documents_embedding ON rag_documents USING ivfflat (embedding vector_cosine_ops);
   ```

## Security Configuration

### SSL/TLS Setup

1. **SSL Certificate:**
   ```bash
   # Using Let's Encrypt
   sudo certbot --nginx -d your-domain.com
   
   # Or using Cloudflare SSL
   # Configure in Cloudflare dashboard
   ```

2. **Security Headers:**
   ```elixir
   # In config/prod.exs
   config :financial_advisor_agent, FinancialAdvisorAgentWeb.Endpoint,
     http: [port: 4000],
     url: [host: "your-domain.com", port: 443, scheme: "https"],
     force_ssl: [rewrite_on: [:x_forwarded_proto]]
   ```

### Environment Security

1. **Secret Management:**
   ```bash
   # Generate secure secrets
   mix phx.gen.secret
   
   # Use environment-specific secrets
   export SECRET_KEY_BASE=$(mix phx.gen.secret)
   export GUARDIAN_SECRET_KEY=$(mix phx.gen.secret)
   ```

2. **Database Security:**
   - Use strong passwords
   - Enable SSL connections
   - Restrict database access
   - Regular security updates

## Monitoring and Logging

### Application Monitoring

1. **Sentry Integration:**
   ```elixir
   # Add to mix.exs
   {:sentry, "~> 8.0"}
   
   # Configure in config/prod.exs
   config :sentry,
     dsn: System.get_env("SENTRY_DSN"),
     environment_name: :prod
   ```

2. **Health Checks:**
   ```bash
   # Add health check endpoint
   curl https://your-domain.com/health
   ```

### Log Management

1. **Structured Logging:**
   ```elixir
   # Configure JSON logging
   config :logger, :console,
     format: "$time $metadata[$level] $message\n",
     metadata: [:request_id, :user_id]
   ```

2. **Log Aggregation:**
   - Use services like LogDNA, Papertrail, or ELK stack
   - Configure log rotation and retention

## Performance Optimization

### Database Optimization

1. **Connection Pooling:**
   ```elixir
   config :financial_advisor_agent, FinancialAdvisorAgent.Repo,
     pool_size: 20,
     queue_target: 5000,
     queue_interval: 2000
   ```

2. **Query Optimization:**
   - Use database indexes
   - Optimize N+1 queries
   - Implement query caching

### Application Optimization

1. **Asset Optimization:**
   ```bash
   # Compress assets
   mix assets.deploy
   
   # Use CDN for static assets
   config :financial_advisor_agent, FinancialAdvisorAgentWeb.Endpoint,
     static_url: [host: "cdn.your-domain.com"]
   ```

2. **Caching Strategy:**
   - Implement Redis caching
   - Use CDN for static content
   - Cache database queries

## Backup and Recovery

### Database Backups

1. **Automated Backups:**
   ```bash
   # Daily backup script
   pg_dump financial_advisor_agent > backup_$(date +%Y%m%d).sql
   ```

2. **Backup Storage:**
   - Use cloud storage (AWS S3, Google Cloud Storage)
   - Implement backup rotation
   - Test restore procedures

### Application Backups

1. **Code Backup:**
   - Use Git for version control
   - Tag production releases
   - Maintain deployment history

2. **Configuration Backup:**
   - Backup environment variables
   - Document configuration changes
   - Version control configuration files

## Scaling Considerations

### Horizontal Scaling

1. **Load Balancing:**
   ```nginx
   upstream phoenix_backend {
       server 127.0.0.1:4000;
       server 127.0.0.1:4001;
       server 127.0.0.1:4002;
   }
   ```

2. **Database Scaling:**
   - Read replicas for query distribution
   - Connection pooling
   - Query optimization

### Vertical Scaling

1. **Resource Monitoring:**
   - CPU and memory usage
   - Database performance metrics
   - Application response times

2. **Auto-scaling:**
   - Configure auto-scaling policies
   - Set up monitoring alerts
   - Implement graceful shutdowns

## Troubleshooting

### Common Issues

1. **Database Connection Issues:**
   ```bash
   # Check database connectivity
   mix ecto.migrate
   
   # Verify connection string
   echo $DATABASE_URL
   ```

2. **Asset Compilation Issues:**
   ```bash
   # Clear and rebuild assets
   rm -rf _build/
   mix deps.get
   mix assets.deploy
   ```

3. **OAuth Configuration Issues:**
   - Verify redirect URIs
   - Check OAuth consent screen
   - Validate API credentials

### Monitoring and Alerts

1. **Health Monitoring:**
   - Set up uptime monitoring
   - Configure error alerting
   - Monitor performance metrics

2. **Log Analysis:**
   - Use log aggregation tools
   - Set up error tracking
   - Monitor user activity

## Maintenance

### Regular Maintenance Tasks

1. **Security Updates:**
   - Keep dependencies updated
   - Apply security patches
   - Monitor vulnerability reports

2. **Performance Monitoring:**
   - Regular performance audits
   - Database optimization
   - Code performance reviews

3. **Backup Verification:**
   - Test backup restoration
   - Verify data integrity
   - Update backup procedures

---

For additional deployment support and advanced configurations, please refer to the platform documentation or contact the development team.