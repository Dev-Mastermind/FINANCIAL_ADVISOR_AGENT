defmodule FinancialAdvisorAgent.Repo do
  use Ecto.Repo,
    otp_app: :financial_advisor_agent,
    adapter: Ecto.Adapters.Postgres
end
