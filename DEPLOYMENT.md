# Deployment Guide

## Prerequisites

1. **GitHub Repository** - Push your code to GitHub
2. **Environment Variables** - Set up all required environment variables
3. **Database** - PostgreSQL database (provided by hosting platform)

## Environment Variables Required

```bash
# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Phoenix
SECRET_KEY_BASE=your-secret-key-base
PHX_HOST=your-domain.com
PORT=4000
MIX_ENV=prod

# OpenAI
OPENAI_API_KEY=your-openai-api-key

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# HubSpot
HUBSPOT_CLIENT_ID=your-hubspot-client-id
HUBSPOT_CLIENT_SECRET=your-hubspot-client-secret
HUBSPOT_REDIRECT_URI=https://your-domain.com/hubspot/callback
```

## Deployment Options

### Option 1: Render (Recommended)

1. **Connect to Render:**
   - Go to [Render Dashboard](https://dashboard.render.com/)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository

2. **Configure Service:**
   - Name: `financial-advisor-agent`
   - Environment: `Elixir`
   - Region: Choose closest to your users
   - Plan: `Starter` (free tier available)

3. **Set Environment Variables:**
   - Add all required environment variables
   - Make sure to use production URLs for OAuth redirects

4. **Deploy:**
   - Render will automatically build and deploy
   - The `render.yaml` file will be used for configuration

### Option 2: Fly.io

1. **Install Fly CLI:**
   ```bash
   curl -L https://fly.io/install.sh | sh
   ```

2. **Login to Fly:**
   ```bash
   fly auth login
   ```

3. **Deploy:**
   ```bash
   fly launch
   fly deploy
   ```

4. **Set Environment Variables:**
   ```bash
   fly secrets set OPENAI_API_KEY=your-key
   fly secrets set GOOGLE_CLIENT_ID=your-id
   fly secrets set GOOGLE_CLIENT_SECRET=your-secret
   fly secrets set HUBSPOT_CLIENT_ID=your-id
   fly secrets set HUBSPOT_CLIENT_SECRET=your-secret
   fly secrets set SECRET_KEY_BASE=your-secret
   ```

### Option 3: Railway

1. **Connect to Railway:**
   - Go to [Railway](https://railway.app/)
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository

2. **Configure:**
   - Railway will auto-detect Elixir
   - Add PostgreSQL database
   - Set environment variables

3. **Deploy:**
   - Railway will automatically build and deploy

## Post-Deployment Setup

1. **Update OAuth Redirect URIs:**
   - Google Cloud Console: Add your production domain
   - HubSpot: Update redirect URI to production domain

2. **Test the Application:**
   - Visit your deployed URL
   - Test Google OAuth login
   - Test HubSpot connection
   - Test AI chat functionality

3. **Monitor:**
   - Check application logs
   - Monitor database connections
   - Set up error tracking (optional)

## Production Considerations

1. **Security:**
   - Use HTTPS in production
   - Set secure session cookies
   - Validate all inputs
   - Rate limit API endpoints

2. **Performance:**
   - Enable database connection pooling
   - Use CDN for static assets
   - Monitor memory usage
   - Set up health checks

3. **Monitoring:**
   - Set up application monitoring
   - Monitor database performance
   - Track API usage
   - Set up alerts

## Troubleshooting

1. **Build Failures:**
   - Check Elixir version compatibility
   - Verify all dependencies are available
   - Check build logs for specific errors

2. **Runtime Errors:**
   - Check environment variables
   - Verify database connectivity
   - Check application logs

3. **OAuth Issues:**
   - Verify redirect URIs match exactly
   - Check client IDs and secrets
   - Ensure HTTPS is enabled

## Scaling

1. **Horizontal Scaling:**
   - Use multiple instances
   - Load balancer configuration
   - Session storage (Redis)

2. **Database Scaling:**
   - Read replicas
   - Connection pooling
   - Query optimization

3. **Caching:**
   - Redis for session storage
   - CDN for static assets
   - Application-level caching
