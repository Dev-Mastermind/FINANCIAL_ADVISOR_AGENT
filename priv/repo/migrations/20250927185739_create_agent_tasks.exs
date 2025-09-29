defmodule FinancialAdvisorAgent.Repo.Migrations.CreateAgentTasks do
  use Ecto.Migration

  def change do
    create table(:agent_tasks) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :title, :string, null: false
      add :description, :text
      add :status, :string, default: "pending", null: false
      add :priority, :integer, default: 0
      add :task_type, :string, null: false
      add :input_data, :map, default: %{}
      add :output_data, :map, default: %{}
      add :error_message, :text
      add :retry_count, :integer, default: 0
      add :max_retries, :integer, default: 3
      add :scheduled_for, :utc_datetime
      add :completed_at, :utc_datetime
      add :context, :map, default: %{}

      timestamps()
    end

    create index(:agent_tasks, [:user_id])
    create index(:agent_tasks, [:status])
    create index(:agent_tasks, [:task_type])
    create index(:agent_tasks, [:scheduled_for])
  end
end
