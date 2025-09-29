defmodule FinancialAdvisorAgent.Services.ServiceFactory do
  @moduledoc """
  Service factory that returns the appropriate service implementation
  based on the current environment configuration.
  """

  @doc """
  Returns the appropriate OpenAI service based on configuration.
  """
  def openai_service do
    if use_mocks?() do
      FinancialAdvisorAgent.AI.MockOpenAIService
    else
      FinancialAdvisorAgent.AI.OpenAIService
    end
  end

  @doc """
  Returns the appropriate HubSpot service based on configuration.
  """
  def hubspot_service do
    if use_mocks?() do
      FinancialAdvisorAgent.ExternalServices.MockHubSpotService
    else
      FinancialAdvisorAgent.ExternalServices.HubSpotService
    end
  end

  @doc """
  Returns the appropriate Gmail service based on configuration.
  """
  def gmail_service do
    if use_mocks?() do
      FinancialAdvisorAgent.ExternalServices.MockGmailService
    else
      FinancialAdvisorAgent.ExternalServices.GmailService
    end
  end

  @doc """
  Returns the appropriate Google OAuth strategy based on configuration.
  """
  def google_oauth_strategy do
    if use_mocks?() do
      FinancialAdvisorAgent.Auth.MockGoogleStrategy
    else
      Ueberauth.Strategy.Google
    end
  end

  @doc """
  Checks if the current environment should use mock services.
  """
  def use_mocks? do
    Application.get_env(:financial_advisor_agent, :external_services, [])
    |> Keyword.get(:use_mocks, false)
  end

  @doc """
  Returns the current mock mode.
  """
  def mock_mode do
    Application.get_env(:financial_advisor_agent, :external_services, [])
    |> Keyword.get(:mock_mode, :development)
  end

  @doc """
  Validates that required environment variables are present for non-mock mode.
  """
  def validate_environment do
    if not use_mocks?() do
      validate_required_vars()
    else
      :ok
    end
  end

  defp validate_required_vars do
    required_vars = [
      "OPENAI_API_KEY",
      "GOOGLE_CLIENT_ID",
      "GOOGLE_CLIENT_SECRET",
      "SECRET_KEY_BASE",
      "GUARDIAN_SECRET_KEY"
    ]

    missing_vars = Enum.filter(required_vars, fn var ->
      System.get_env(var) == nil
    end)

    if length(missing_vars) > 0 do
      {:error, "Missing required environment variables: #{Enum.join(missing_vars, ", ")}"}
    else
      :ok
    end
  end
end
