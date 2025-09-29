defmodule FinancialAdvisorAgent.Integrations.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "integrations" do
    field :integration_type, :string
    field :external_id, :string
    field :name, :string
    field :config, :map, default: %{}
    field :is_active, :boolean, default: true
    field :last_sync_at, :utc_datetime
    field :sync_status, :string, default: "pending"

    belongs_to :user, FinancialAdvisorAgent.Accounts.User

    timestamps()
  end

  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [
      :integration_type, :external_id, :name, :config, :is_active,
      :last_sync_at, :sync_status, :user_id
    ])
    |> validate_required([:integration_type, :external_id, :user_id])
    |> validate_inclusion(:integration_type, ["gmail", "calendar", "hubspot"])
    |> validate_inclusion(:sync_status, ["pending", "syncing", "completed", "failed"])
    |> unique_constraint([:user_id, :integration_type, :external_id])
    |> foreign_key_constraint(:user_id)
  end

  def gmail_changeset(integration, gmail_data, user_id) do
    changeset(integration, %{
      integration_type: "gmail",
      external_id: gmail_data.email,
      name: "Gmail - #{gmail_data.email}",
      config: %{
        email: gmail_data.email,
        access_token: gmail_data.access_token,
        refresh_token: gmail_data.refresh_token,
        expires_at: gmail_data.expires_at
      },
      user_id: user_id
    })
  end

  def calendar_changeset(integration, calendar_data, user_id) do
    changeset(integration, %{
      integration_type: "calendar",
      external_id: calendar_data.calendar_id,
      name: "Calendar - #{calendar_data.calendar_id}",
      config: %{
        calendar_id: calendar_data.calendar_id,
        access_token: calendar_data.access_token,
        refresh_token: calendar_data.refresh_token,
        expires_at: calendar_data.expires_at
      },
      user_id: user_id
    })
  end

  def hubspot_changeset(integration, hubspot_data, user_id) do
    changeset(integration, %{
      integration_type: "hubspot",
      external_id: hubspot_data.portal_id,
      name: "HubSpot - #{hubspot_data.portal_id}",
      config: %{
        portal_id: hubspot_data.portal_id,
        access_token: hubspot_data.access_token,
        refresh_token: hubspot_data.refresh_token,
        expires_at: hubspot_data.expires_at
      },
      user_id: user_id
    })
  end
end
