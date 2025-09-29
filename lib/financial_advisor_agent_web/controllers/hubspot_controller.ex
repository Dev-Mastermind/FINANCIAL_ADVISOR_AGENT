defmodule FinancialAdvisorAgentWeb.HubspotController do
  use FinancialAdvisorAgentWeb, :controller

  alias FinancialAdvisorAgent.Accounts
  alias FinancialAdvisorAgent.Integrations

  def connect(conn, _params) do
    user_id = get_session(conn, :user_id)
    
    if user_id do
      # For development, create a mock HubSpot integration
      # In production, this would redirect to HubSpot OAuth
      case create_mock_hubspot_integration(user_id) do
        {:ok, _integration} ->
          conn
          |> put_flash(:info, "HubSpot connected successfully!")
          |> redirect(to: ~p"/dashboard")
        {:error, changeset} ->
          conn
          |> put_flash(:error, "Failed to connect HubSpot: #{inspect(changeset.errors)}")
          |> redirect(to: ~p"/dashboard")
      end
    else
      conn
      |> put_flash(:error, "Please log in first.")
      |> redirect(to: ~p"/")
    end
  end

  def callback(conn, _params) do
    # This would handle the real HubSpot OAuth callback in production
    conn
    |> put_flash(:info, "HubSpot OAuth callback received.")
    |> redirect(to: ~p"/dashboard")
  end

  # Private function to create a mock HubSpot integration for development
  defp create_mock_hubspot_integration(user_id) do
    hubspot_integration_params = %{
      integration_type: "hubspot",
      external_id: "mock_hubspot_123",
      name: "HubSpot CRM",
      config: %{
        "access_token" => "mock_hubspot_access_token",
        "refresh_token" => "mock_hubspot_refresh_token",
        "expires_at" => DateTime.add(DateTime.utc_now(), 3600, :second),
        "portal_id" => "12345678"
      },
      is_active: true,
      sync_status: "completed"
    }

    case Integrations.get_integration_by_type(user_id, "hubspot") do
      nil ->
        # Create new HubSpot integration
        case Integrations.create_integration(Map.put(hubspot_integration_params, :user_id, user_id)) do
          {:ok, integration} ->
            IO.inspect(integration, label: "Created HubSpot integration")
            {:ok, integration}
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Failed to create HubSpot integration")
            {:error, changeset}
        end
      existing_integration ->
        # Update existing HubSpot integration
        case Integrations.update_integration(existing_integration, hubspot_integration_params) do
          {:ok, integration} ->
            IO.inspect(integration, label: "Updated HubSpot integration")
            {:ok, integration}
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Failed to update HubSpot integration")
            {:error, changeset}
        end
    end
  end
end
