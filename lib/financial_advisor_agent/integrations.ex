defmodule FinancialAdvisorAgent.Integrations do
  @moduledoc """
  The Integrations context for managing external service integrations.
  """

  import Ecto.Query, warn: false
  alias FinancialAdvisorAgent.Repo
  alias FinancialAdvisorAgent.Integrations.Integration

  def get_integration!(id), do: Repo.get!(Integration, id)

  def get_integration(id), do: Repo.get(Integration, id)

  def list_integrations_for_user(user_id) do
    from(i in Integration, where: i.user_id == ^user_id, order_by: [desc: i.inserted_at])
    |> Repo.all()
  end

  def list_active_integrations_for_user(user_id) do
    from(i in Integration, where: i.user_id == ^user_id and i.is_active == true)
    |> Repo.all()
  end

  def get_integration_by_type(user_id, integration_type) do
    from(i in Integration, where: i.user_id == ^user_id and i.integration_type == ^integration_type)
    |> Repo.one()
  end

  def create_integration(attrs \\ %{}) do
    %Integration{}
    |> Integration.changeset(attrs)
    |> Repo.insert()
  end

  def create_gmail_integration(gmail_data, user_id) do
    %Integration{}
    |> Integration.gmail_changeset(gmail_data, user_id)
    |> Repo.insert()
  end

  def create_calendar_integration(calendar_data, user_id) do
    %Integration{}
    |> Integration.calendar_changeset(calendar_data, user_id)
    |> Repo.insert()
  end

  def create_hubspot_integration(hubspot_data, user_id) do
    %Integration{}
    |> Integration.hubspot_changeset(hubspot_data, user_id)
    |> Repo.insert()
  end

  def update_integration(%Integration{} = integration, attrs) do
    integration
    |> Integration.changeset(attrs)
    |> Repo.update()
  end

  def update_sync_status(%Integration{} = integration, status, last_sync_at \\ nil) do
    integration
    |> Integration.changeset(%{
      sync_status: status,
      last_sync_at: last_sync_at || DateTime.utc_now()
    })
    |> Repo.update()
  end

  def delete_integration(%Integration{} = integration) do
    Repo.delete(integration)
  end

  def change_integration(%Integration{} = integration, attrs \\ %{}) do
    Integration.changeset(integration, attrs)
  end

  def get_user_integrations(user_id) do
    integrations = list_active_integrations_for_user(user_id)
    
    %{
      gmail: get_integration_by_type(user_id, "gmail"),
      calendar: get_integration_by_type(user_id, "calendar"),
      hubspot: get_integration_by_type(user_id, "hubspot"),
      all: integrations
    }
  end
end
