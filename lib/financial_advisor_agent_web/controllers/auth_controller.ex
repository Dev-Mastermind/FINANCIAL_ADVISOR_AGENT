defmodule FinancialAdvisorAgentWeb.AuthController do
  use FinancialAdvisorAgentWeb, :controller

  alias FinancialAdvisorAgent.Accounts
  alias FinancialAdvisorAgent.Integrations

  def request(conn, %{"provider" => "google"}) do
    # Check if we should use real Google OAuth
    if Application.get_env(:financial_advisor_agent, :external_services)[:use_real_google_oauth] do
      # Use real Google OAuth - redirect to Google's OAuth page
      redirect(conn, external: Ueberauth.Strategy.Google.authorize_url!(conn))
    else
      # Use mock authentication for development
      mock_user = %{
        email: "devawais.cs@gmail.com",
        name: "Dev Awais",
        google_uid: "mock_user_123",
        google_access_token: "mock_access_token",
        google_refresh_token: "mock_refresh_token",
        google_token_expires_at: DateTime.add(DateTime.utc_now(), 3600, :second)
      }

      case Accounts.get_user_by_google_uid("mock_user_123") do
        nil ->
          case Accounts.create_user(mock_user) do
            {:ok, user} ->
              conn
              |> put_session(:user_id, user.id)
              |> put_flash(:info, "Successfully authenticated with mock user.")
              |> redirect(to: ~p"/dashboard")
            {:error, changeset} ->
              conn
              |> put_flash(:error, "Failed to create user: #{inspect(changeset.errors)}")
              |> redirect(to: ~p"/")
          end
        user ->
          case Accounts.update_google_tokens(user, mock_user) do
            {:ok, updated_user} ->
              conn
              |> put_session(:user_id, updated_user.id)
              |> put_flash(:info, "Successfully authenticated with mock user.")
              |> redirect(to: ~p"/dashboard")
            {:error, changeset} ->
              conn
              |> put_flash(:error, "Failed to update tokens: #{inspect(changeset.errors)}")
              |> redirect(to: ~p"/")
          end
      end
    end
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    # Handle successful Google OAuth authentication
    # Convert Unix timestamp to DateTime if needed
    expires_at = case auth.credentials.expires_at do
      nil -> nil
      timestamp when is_integer(timestamp) -> DateTime.from_unix!(timestamp)
      %DateTime{} = dt -> dt
      _ -> nil
    end

    user_params = %{
      email: auth.info.email,
      name: auth.info.name,
      google_uid: auth.uid,
      google_access_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token,
      google_token_expires_at: expires_at
    }

    case Accounts.get_user_by_google_uid(auth.uid) do
      nil ->
        case Accounts.create_user(user_params) do
          {:ok, user} ->
            # Create Gmail and Calendar integrations for new user
            create_google_integrations(user)
            
            conn
            |> put_session(:user_id, user.id)
            |> put_flash(:info, "Successfully authenticated.")
            |> redirect(to: ~p"/dashboard")
          {:error, changeset} ->
            conn
            |> put_flash(:error, "Failed to create user: #{inspect(changeset.errors)}")
            |> redirect(to: ~p"/")
        end
      user ->
        case Accounts.update_google_tokens(user, user_params) do
          {:ok, updated_user} ->
            # Update or create Gmail and Calendar integrations for existing user
            create_google_integrations(updated_user)
            
            conn
            |> put_session(:user_id, updated_user.id)
            |> put_flash(:info, "Successfully authenticated.")
            |> redirect(to: ~p"/dashboard")
          {:error, changeset} ->
            conn
            |> put_flash(:error, "Failed to update tokens: #{inspect(changeset.errors)}")
            |> redirect(to: ~p"/")
        end
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: ~p"/")
  end

  # Private function to create or update Google integrations
  defp create_google_integrations(user) do
    IO.inspect(user.id, label: "Creating Google integrations for user")
    # Create or update Gmail integration
    gmail_integration_params = %{
      integration_type: "gmail",
      external_id: user.google_uid,
      name: "Gmail",
      config: %{
        "access_token" => user.google_access_token,
        "refresh_token" => user.google_refresh_token,
        "expires_at" => user.google_token_expires_at
      },
      is_active: true,
      sync_status: "completed"
    }

    case Integrations.get_integration_by_type(user.id, "gmail") do
      nil ->
        # Create new Gmail integration
        case Integrations.create_integration(Map.put(gmail_integration_params, :user_id, user.id)) do
          {:ok, integration} ->
            IO.inspect(integration, label: "Created Gmail integration")
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Failed to create Gmail integration")
        end
      existing_integration ->
        # Update existing Gmail integration
        case Integrations.update_integration(existing_integration, gmail_integration_params) do
          {:ok, integration} ->
            IO.inspect(integration, label: "Updated Gmail integration")
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Failed to update Gmail integration")
        end
    end

    # Create or update Calendar integration
    calendar_integration_params = %{
      integration_type: "calendar",
      external_id: user.google_uid,
      name: "Google Calendar",
      config: %{
        "access_token" => user.google_access_token,
        "refresh_token" => user.google_refresh_token,
        "expires_at" => user.google_token_expires_at
      },
      is_active: true,
      sync_status: "completed"
    }

    case Integrations.get_integration_by_type(user.id, "calendar") do
      nil ->
        # Create new Calendar integration
        case Integrations.create_integration(Map.put(calendar_integration_params, :user_id, user.id)) do
          {:ok, integration} ->
            IO.inspect(integration, label: "Created Calendar integration")
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Failed to create Calendar integration")
        end
      existing_integration ->
        # Update existing Calendar integration
        case Integrations.update_integration(existing_integration, calendar_integration_params) do
          {:ok, integration} ->
            IO.inspect(integration, label: "Updated Calendar integration")
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Failed to update Calendar integration")
        end
    end
  end
end