defmodule FinancialAdvisorAgent.Agent.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agent_tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "pending"
    field :priority, :integer, default: 0
    field :task_type, :string
    field :input_data, :map, default: %{}
    field :output_data, :map, default: %{}
    field :error_message, :string
    field :retry_count, :integer, default: 0
    field :max_retries, :integer, default: 3
    field :scheduled_for, :utc_datetime
    field :completed_at, :utc_datetime
    field :context, :map, default: %{}

    belongs_to :user, FinancialAdvisorAgent.Accounts.User

    timestamps()
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :title, :description, :status, :priority, :task_type, :input_data,
      :output_data, :error_message, :retry_count, :max_retries, :scheduled_for,
      :completed_at, :context, :user_id
    ])
    |> validate_required([:title, :task_type, :user_id])
    |> validate_inclusion(:status, ["pending", "in_progress", "completed", "failed", "cancelled"])
    |> validate_inclusion(:task_type, [
      "schedule_appointment", "send_email", "create_contact", "update_contact",
      "search_emails", "search_calendar", "search_hubspot", "general_instruction"
    ])
    |> foreign_key_constraint(:user_id)
  end

  def status_changeset(task, status, attrs \\ %{}) do
    changeset_data = case status do
      "completed" -> Map.put(attrs, :completed_at, DateTime.utc_now())
      "failed" -> Map.put(attrs, :retry_count, (task.retry_count || 0) + 1)
      _ -> attrs
    end

    task
    |> cast(changeset_data, [:status, :completed_at, :retry_count, :error_message, :output_data])
    |> validate_required([:status])
    |> validate_inclusion(:status, ["pending", "in_progress", "completed", "failed", "cancelled"])
  end
end
