defmodule FinancialAdvisorAgent.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :integration_type, :string, null: false
      add :external_id, :string, null: false
      add :name, :string
      add :config, :map, default: %{}
      add :is_active, :boolean, default: true
      add :last_sync_at, :utc_datetime
      add :sync_status, :string, default: "pending"

      timestamps()
    end

    create index(:integrations, [:user_id])
    create index(:integrations, [:integration_type])
    create index(:integrations, [:external_id])
    create index(:integrations, [:is_active])
    create unique_index(:integrations, [:user_id, :integration_type, :external_id])
  end
end
