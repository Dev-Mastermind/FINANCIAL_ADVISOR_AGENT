# Financial Advisor Agent - Setup Instructions

## Prerequisites

1. **Elixir and Phoenix** - Already installed
2. **PostgreSQL** - Install if not already installed
3. **Node.js** - For asset compilation

## Environment Configuration

The application supports different configurations for development, staging, and production environments.

### Development Environment (Recommended for Local Development)

**No API keys required!** The application automatically uses mock services in development.

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **The .env file is optional for development** - you can leave all values as placeholders or empty. The app will use mock services automatically.

3. **If you want to test with real services in development:**
   - Set your real API keys in the `.env` file
   - The app will use real services instead of mocks

### Staging/Production Environment

**All API keys are required** for staging and production environments.

Create a `.env` file with real values:

```bash
# Database (Required)
DATABASE_URL=postgresql://user:password@host:port/database

# OpenAI (Required)
OPENAI_API_KEY=sk-proj-your-real-openai-key

# Google OAuth (Required)
GOOGLE_CLIENT_ID=your-real-google-client-id
GOOGLE_CLIENT_SECRET=your-real-google-client-secret

# HubSpot (Required)
HUBSPOT_CLIENT_ID=your-real-hubspot-client-id
HUBSPOT_CLIENT_SECRET=your-real-hubspot-client-secret
HUBSPOT_REDIRECT_URI=https://your-domain.com/hubspot/callback

# Secret Keys (Required)
SECRET_KEY_BASE=your-real-secret-key-base
GUARDIAN_SECRET_KEY=your-real-guardian-secret-key

# Phoenix Configuration (Required)
PHX_HOST=your-domain.com
PORT=4000
MIX_ENV=prod
```

## Setup Steps

### Quick Start (Development with Mocks)

1. **Install dependencies:**
   ```bash
   mix deps.get
   ```

2. **Set up the database:**
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

3. **Install assets:**
   ```bash
   mix assets.setup
   mix assets.build
   ```

4. **Start the server:**
   ```bash
   mix phx.server
   ```

**That's it!** The application will run with mock services - no API keys needed.

### Development with Real Services (Optional)

If you want to test with real services in development:

1. **Set up your API keys** (see sections below)
2. **Create a `.env` file** with your real API keys
3. **Start the server** - it will use real services instead of mocks

## Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable Gmail API and Google Calendar API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URIs:
   - `http://localhost:4000/auth/google/callback`
6. Copy Client ID and Client Secret to your `.env` file

## HubSpot Setup

1. Go to [HubSpot Developer Portal](https://developers.hubspot.com/)
2. Create a new app
3. Configure OAuth settings:
   - Redirect URI: `http://localhost:4000/hubspot/callback`
   - Scopes: `contacts`, `crm.objects.contacts.read`, `crm.objects.contacts.write`
4. Copy Client ID and Client Secret to your `.env` file

## OpenAI Setup

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create an API key
3. Add the key to your `.env` file

## Features

- **Google OAuth Integration** - Login with Google account
- **Gmail Integration** - Read and send emails
- **Calendar Integration** - Schedule and manage appointments
- **HubSpot Integration** - Manage CRM contacts and notes
- **AI Chat Interface** - ChatGPT-like interface for interacting with the AI
- **RAG (Retrieval-Augmented Generation)** - AI uses your data to answer questions
- **Tool Calling** - AI can perform actions like scheduling, emailing, etc.
- **Task Management** - Track and manage AI tasks
- **Memory System** - AI remembers instructions and preferences

## Usage

### Development Mode (with Mocks)

1. Visit `http://localhost:4000`
2. Click "Login with Google" (uses mock authentication)
3. The app will simulate Google OAuth with mock user data
4. Connect HubSpot (optional - uses mock HubSpot integration)
5. Start chatting with the AI assistant (uses mock OpenAI responses)

### Production Mode (with Real Services)

1. Visit your production URL
2. Click "Login with Google" (real Google OAuth)
3. Authorize the application with your Google account
4. Connect HubSpot (optional - real HubSpot integration)
5. Start chatting with the AI assistant (real OpenAI responses)

## Mock Services

In development mode, the following services are mocked:

- **OpenAI API** - Returns realistic AI responses without API calls
- **Google OAuth** - Simulates authentication with mock user data
- **HubSpot API** - Returns mock CRM data and contacts
- **Gmail API** - Returns mock email data
- **All external integrations** - Work with fake data

This allows you to develop and test the application without needing real API keys or making external API calls.

## Deployment

For production deployment, set the following environment variables:

- `DATABASE_URL` - PostgreSQL connection string
- `SECRET_KEY_BASE` - Phoenix secret key
- `OPENAI_API_KEY` - OpenAI API key
- `HUBSPOT_CLIENT_ID` - HubSpot OAuth client ID
- `HUBSPOT_CLIENT_SECRET` - HubSpot OAuth client secret
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `GOOGLE_CLIENT_SECRET` - Google OAuth client secret
- `PHX_HOST` - Your domain name
- `PORT` - Port number (default: 4000)

## Architecture

The application is built with:

- **Phoenix Framework** - Web framework
- **Ecto** - Database ORM
- **PostgreSQL** - Database with pgvector extension for embeddings
- **Ueberauth** - OAuth authentication
- **OpenAI API** - AI/LLM integration
- **Tailwind CSS** - Styling
- **LiveView** - Real-time UI updates
