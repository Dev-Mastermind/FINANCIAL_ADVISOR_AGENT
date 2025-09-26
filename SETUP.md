# Financial Advisor Platform - Setup Instructions

## Prerequisites

1. **Elixir 1.18.4+** - Functional programming language
2. **Phoenix Framework** - Web framework for Elixir
3. **PostgreSQL 17+** - Database with vector search capabilities
4. **Node.js 18+** - For asset compilation and frontend tooling

## Environment Configuration

The platform supports different configurations for development, staging, and production environments with flexible service integration options.

### Development Environment (Recommended for Local Development)

**Mock services enabled by default** for seamless development without external dependencies.

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Development mode uses mock services** - No external API keys required for basic functionality.

3. **To test with real services in development:**
   - Configure your API keys in the `.env` file
   - The platform will automatically switch to real service integrations

### Staging/Production Environment

**Production-ready configuration** with full service integrations.

Create a `.env` file with production values:

```bash
# Database Configuration
DATABASE_URL=postgresql://user:password@host:port/database

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
SECRET_KEY_BASE=your-production-secret-key-base
GUARDIAN_SECRET_KEY=your-production-guardian-secret-key
```

## Setup Steps

### 1. Database Setup

```bash
# Create the database
mix ecto.create

# Run migrations
mix ecto.migrate

# Optional: Seed with sample data
mix run priv/repo/seeds.exs
```

### 2. Asset Compilation

```bash
# Install dependencies
mix deps.get

# Compile assets
mix assets.deploy
```

### 3. Start the Application

```bash
# Development server
mix phx.server

# Or with IEx console
iex -S mix phx.server
```

## Service Integrations

### Google OAuth Setup

1. **Google Cloud Console Configuration:**
   - Create a new project in [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Gmail API and Google Calendar API
   - Configure OAuth consent screen
   - Add authorized redirect URIs:
     - `http://localhost:4000/auth/google/callback` (development)
     - `https://your-domain.com/auth/google/callback` (production)

2. **OAuth Credentials:**
   - Create OAuth 2.0 Client ID
   - Download credentials and add to `.env` file
   - Configure authorized domains and redirect URIs

### HubSpot Integration Setup

1. **HubSpot Developer Account:**
   - Create a HubSpot developer account
   - Generate a private app with required scopes:
     - `contacts.read`
     - `contacts.write`
     - `crm.objects.contacts.read`
     - `crm.objects.contacts.write`

2. **API Configuration:**
   - Copy the access token to your `.env` file
   - Configure webhook endpoints for real-time updates

### OpenAI Integration Setup

1. **OpenAI Platform:**
   - Create an account at [OpenAI Platform](https://platform.openai.com/)
   - Generate an API key with appropriate usage limits
   - Configure billing and usage monitoring

2. **API Configuration:**
   - Add the API key to your `.env` file
   - Configure model preferences and rate limits

## Docker Deployment

### Quick Start with Docker

```bash
# Build and start all services
docker-compose up --build

# Run in background
docker-compose up -d
```

### Production Docker Setup

```bash
# Use production configuration
docker-compose -f docker-compose.yml up -d

# Check service status
docker-compose ps

# View logs
docker-compose logs -f
```

## Configuration Options

### Mock Services (Development)

The platform includes comprehensive mock services for development:

- **Mock OpenAI Service**: Simulates AI responses for testing
- **Mock Gmail Service**: Simulates email operations
- **Mock HubSpot Service**: Simulates CRM operations
- **Mock Google OAuth**: Simulates authentication flow

### Real Services (Production)

Production configuration uses actual service integrations:

- **OpenAI GPT-4**: Real AI-powered financial advisory
- **Gmail API**: Actual email integration and analysis
- **Google Calendar**: Real calendar management
- **HubSpot CRM**: Live CRM synchronization

## Environment Variables Reference

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string | Yes | `ecto://postgres:postgres@localhost/financial_advisor_agent_dev` |
| `OPENAI_API_KEY` | OpenAI API key for AI services | Production | Mock service |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID | Production | Mock OAuth |
| `GOOGLE_CLIENT_SECRET` | Google OAuth client secret | Production | Mock OAuth |
| `HUBSPOT_API_KEY` | HubSpot API key | Production | Mock CRM |
| `SECRET_KEY_BASE` | Phoenix secret key | Yes | Generated |
| `GUARDIAN_SECRET_KEY` | JWT secret key | Yes | Generated |

## Troubleshooting

### Common Issues

1. **Database Connection Issues:**
   ```bash
   # Check PostgreSQL status
   brew services list | grep postgres
   
   # Restart PostgreSQL
   brew services restart postgresql
   ```

2. **Asset Compilation Issues:**
   ```bash
   # Clear compiled assets
   rm -rf _build/
   mix deps.get
   mix assets.deploy
   ```

3. **OAuth Configuration Issues:**
   - Verify redirect URIs match exactly
   - Check OAuth consent screen configuration
   - Ensure APIs are enabled in Google Cloud Console

### Development Tips

1. **Hot Reloading**: The development server supports hot reloading for instant updates
2. **Database Reset**: Use `mix ecto.reset` to reset database with fresh migrations
3. **Asset Watching**: Assets are automatically recompiled on changes
4. **Console Access**: Use `iex -S mix phx.server` for interactive development

## Security Considerations

### Development Security
- Mock services don't expose real data
- Local development uses HTTP (not HTTPS)
- Database uses local connections only

### Production Security
- All communications use HTTPS
- OAuth tokens are encrypted at rest
- Database connections are secured
- API keys are environment-specific
- Regular security updates and monitoring

## Performance Optimization

### Development Performance
- Fast compilation with incremental builds
- Hot reloading for instant feedback
- Mock services for rapid iteration

### Production Performance
- Optimized database queries
- Connection pooling
- Asset compression and caching
- CDN integration for static assets

## Monitoring and Logging

### Development Logging
- Detailed request/response logging
- Database query logging
- Error tracking and debugging

### Production Monitoring
- Application performance monitoring
- Error tracking and alerting
- Usage analytics and reporting
- Security monitoring and audit logs

---

For additional support and documentation, please refer to the project documentation or contact the development team.