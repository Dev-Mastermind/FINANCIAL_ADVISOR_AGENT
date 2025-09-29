defmodule FinancialAdvisorAgent.Auth.MockGoogleStrategy do
  @moduledoc """
  Mock Google OAuth strategy for development environment.
  Provides fake authentication responses.
  """

  require Logger

  def authorize_url!(_conn) do
    Logger.info("Mock Google OAuth: Generating mock authorization URL")
    
    # Return a mock authorization URL
    "https://mock-accounts.google.com/oauth/authorize?client_id=mock-client-id&redirect_uri=http://localhost:4000/auth/google/callback&response_type=code&scope=email%20profile"
  end

  def callback(_conn, params) do
    Logger.info("Mock Google OAuth: Processing mock callback with params: #{inspect(params)}")
    
    # Simulate processing delay
    Process.sleep(100)
    
    # Return mock user info
    mock_user = %Ueberauth.Auth{
      provider: :google,
      strategy: __MODULE__,
      uid: "mock_user_#{System.unique_integer([:positive])}",
      info: %Ueberauth.Auth.Info{
        name: "Mock User",
        first_name: "Mock",
        last_name: "User",
        email: "mock.user@example.com",
        image: "https://via.placeholder.com/150"
      },
      credentials: %Ueberauth.Auth.Credentials{
        token: "mock_access_token_#{System.unique_integer([:positive])}",
        refresh_token: "mock_refresh_token_#{System.unique_integer([:positive])}",
        expires_at: DateTime.add(DateTime.utc_now(), 3600, :second),
        token_type: "Bearer",
        scopes: ["email", "profile", "https://www.googleapis.com/auth/gmail.readonly"]
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          "id" => "mock_user_#{System.unique_integer([:positive])}",
          "email" => "mock.user@example.com",
          "verified_email" => true,
          "name" => "Mock User",
          "given_name" => "Mock",
          "family_name" => "User",
          "picture" => "https://via.placeholder.com/150",
          "locale" => "en"
        }
      }
    }
    
    {:ok, mock_user}
  end

  def handle_callback!(_conn) do
    Logger.info("Mock Google OAuth: Handling mock callback")
    
    # Return mock auth info
    %Ueberauth.Auth{
      provider: :google,
      strategy: __MODULE__,
      uid: "mock_user_#{System.unique_integer([:positive])}",
      info: %Ueberauth.Auth.Info{
        name: "Mock User",
        first_name: "Mock",
        last_name: "User",
        email: "mock.user@example.com",
        image: "https://via.placeholder.com/150"
      },
      credentials: %Ueberauth.Auth.Credentials{
        token: "mock_access_token_#{System.unique_integer([:positive])}",
        refresh_token: "mock_refresh_token_#{System.unique_integer([:positive])}",
        expires_at: DateTime.add(DateTime.utc_now(), 3600, :second),
        token_type: "Bearer",
        scopes: ["email", "profile", "https://www.googleapis.com/auth/gmail.readonly"]
      },
      extra: %Ueberauth.Auth.Extra{
        raw_info: %{
          "id" => "mock_user_#{System.unique_integer([:positive])}",
          "email" => "mock.user@example.com",
          "verified_email" => true,
          "name" => "Mock User",
          "given_name" => "Mock",
          "family_name" => "User",
          "picture" => "https://via.placeholder.com/150",
          "locale" => "en"
        }
      }
    }
  end
end
