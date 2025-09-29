defmodule FinancialAdvisorAgent.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :google_uid, :string
    field :google_access_token, :string
    field :google_refresh_token, :string
    field :google_token_expires_at, :utc_datetime
    field :hubspot_access_token, :string
    field :hubspot_refresh_token, :string
    field :hubspot_token_expires_at, :utc_datetime
    field :hubspot_portal_id, :string
    field :is_active, :boolean, default: true
    field :preferences, :map, default: %{}

    has_many :agent_tasks, FinancialAdvisorAgent.Agent.Task
    has_many :agent_memory, FinancialAdvisorAgent.Agent.Memory
    has_many :rag_documents, FinancialAdvisorAgent.RAG.Document
    has_many :integrations, FinancialAdvisorAgent.Integrations.Integration

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email, :name, :google_uid, :google_access_token, :google_refresh_token,
      :google_token_expires_at, :hubspot_access_token, :hubspot_refresh_token,
      :hubspot_token_expires_at, :hubspot_portal_id, :is_active, :preferences
    ])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint(:email)
    |> unique_constraint(:google_uid)
  end

  def google_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :google_uid, :google_access_token, :google_refresh_token, :google_token_expires_at
    ])
    |> validate_required([:google_uid])
  end

  def hubspot_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :hubspot_access_token, :hubspot_refresh_token, :hubspot_token_expires_at, :hubspot_portal_id
    ])
    |> validate_required([:hubspot_access_token])
  end
end
