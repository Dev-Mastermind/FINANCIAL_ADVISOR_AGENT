import Config

# Staging Environment Configuration
# Use real services but with staging-specific settings

# OpenAI Configuration - Real API key required
config :financial_advisor_agent, :openai,
  api_key: System.get_env("OPENAI_API_KEY"),
  use_mock: false

# HubSpot Configuration - Real credentials required
config :financial_advisor_agent, :hubspot,
  client_id: System.get_env("HUBSPOT_CLIENT_ID"),
  client_secret: System.get_env("HUBSPOT_CLIENT_SECRET"),
  redirect_uri: System.get_env("HUBSPOT_REDIRECT_URI"),
  use_mock: false

# Google OAuth Configuration - Real credentials required
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [
      default_scope: "email profile https://www.googleapis.com/auth/gmail.readonly https://www.googleapis.com/auth/gmail.send https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/calendar.events",
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET")
    ]}
  ]

# Guardian Configuration - Real secret required
config :financial_advisor_agent, FinancialAdvisorAgent.Guardian,
  issuer: "FinancialAdvisorAgent",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Disable mock mode for staging
config :financial_advisor_agent, :external_services,
  use_mocks: false,
  mock_mode: :staging

# Staging-specific database configuration
config :financial_advisor_agent, FinancialAdvisorAgent.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10,
  ssl: true

# Staging endpoint configuration
config :financial_advisor_agent, FinancialAdvisorAgentWeb.Endpoint,
  url: [host: System.get_env("PHX_HOST", "staging.financial-advisor-agent.com")],
  http: [port: String.to_integer(System.get_env("PORT", "4000"))],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Staging logging
config :logger, level: :info
