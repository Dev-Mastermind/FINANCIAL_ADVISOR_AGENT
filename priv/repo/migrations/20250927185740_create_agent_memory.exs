defmodule FinancialAdvisorAgent.Repo.Migrations.CreateAgentMemory do
  use Ecto.Migration

  def change do
    create table(:agent_memory) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :memory_type, :string, null: false
      add :key, :string, null: false
      add :value, :text, null: false
      add :metadata, :map, default: %{}
      add :expires_at, :utc_datetime

      timestamps()
    end

    create index(:agent_memory, [:user_id])
    create index(:agent_memory, [:memory_type])
    create index(:agent_memory, [:key])
    create index(:agent_memory, [:expires_at])
    create unique_index(:agent_memory, [:user_id, :memory_type, :key])
  end
end
