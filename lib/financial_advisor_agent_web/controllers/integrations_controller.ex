defmodule FinancialAdvisorAgentWeb.IntegrationsController do
  use FinancialAdvisorAgentWeb, :controller

  alias FinancialAdvisorAgent.Integrations

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)
    
    if user_id do
      integrations = Integrations.get_user_integrations(user_id)
      render(conn, :index, integrations: integrations)
    else
      conn
      |> put_flash(:error, "Please log in first.")
      |> redirect(to: ~p"/")
    end
  end

  def connect_hubspot(conn, _params) do
    redirect(conn, to: ~p"/hubspot/connect")
  end

  def sync_data(conn, %{"integration" => integration_type}) do
    user_id = get_session(conn, :user_id)
    
    if user_id do
      case integration_type do
        "gmail" ->
          # Trigger Gmail sync
          Task.async(fn -> 
            FinancialAdvisorAgent.ExternalServices.GmailService.sync_emails(user_id)
          end)
        "calendar" ->
          # Trigger Calendar sync
          Task.async(fn -> 
            FinancialAdvisorAgent.ExternalServices.CalendarService.sync_events(user_id)
          end)
        "hubspot" ->
          # Trigger HubSpot sync
          Task.async(fn -> 
            FinancialAdvisorAgent.ExternalServices.HubSpotService.sync_contacts(user_id)
            FinancialAdvisorAgent.ExternalServices.HubSpotService.sync_notes(user_id)
          end)
      end
      
      conn
      |> put_flash(:info, "Sync started for #{integration_type}")
      |> redirect(to: ~p"/integrations")
    else
      conn
      |> put_flash(:error, "Please log in first.")
      |> redirect(to: ~p"/")
    end
  end
end
