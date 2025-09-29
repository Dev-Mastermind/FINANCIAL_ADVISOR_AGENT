defmodule FinancialAdvisorAgent.Agent.Memory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agent_memory" do
    field :memory_type, :string
    field :key, :string
    field :value, :string
    field :metadata, :map, default: %{}
    field :expires_at, :utc_datetime

    belongs_to :user, FinancialAdvisorAgent.Accounts.User

    timestamps()
  end

  def changeset(memory, attrs) do
    memory
    |> cast(attrs, [:memory_type, :key, :value, :metadata, :expires_at, :user_id])
    |> validate_required([:memory_type, :key, :value, :user_id])
    |> validate_inclusion(:memory_type, [
      "instruction", "preference", "context", "conversation", "task_result"
    ])
    |> unique_constraint([:user_id, :memory_type, :key])
    |> foreign_key_constraint(:user_id)
  end

  def instruction_changeset(memory, instruction, user_id) do
    changeset(memory, %{
      memory_type: "instruction",
      key: "general_instruction",
      value: instruction,
      user_id: user_id
    })
  end

  def preference_changeset(memory, key, value, user_id) do
    changeset(memory, %{
      memory_type: "preference",
      key: key,
      value: value,
      user_id: user_id
    })
  end
end
