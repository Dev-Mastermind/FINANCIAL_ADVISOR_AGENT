defmodule FinancialAdvisorAgent.Agent do
  @moduledoc """
  The Agent context for managing AI agent tasks and memory.
  """

  import Ecto.Query, warn: false
  alias FinancialAdvisorAgent.Repo
  alias FinancialAdvisorAgent.Agent.{Task, Memory}

  # Task functions
  def get_task!(id), do: Repo.get!(Task, id)

  def get_task(id), do: Repo.get(Task, id)

  def list_tasks_for_user(user_id) do
    from(t in Task, where: t.user_id == ^user_id, order_by: [desc: t.inserted_at])
    |> Repo.all()
  end

  def list_pending_tasks_for_user(user_id) do
    from(t in Task, where: t.user_id == ^user_id and t.status == "pending", order_by: [asc: t.priority, asc: t.inserted_at])
    |> Repo.all()
  end

  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def update_task_status(%Task{} = task, status, attrs \\ %{}) do
    task
    |> Task.status_changeset(status, attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  # Memory functions
  def get_memory!(id), do: Repo.get!(Memory, id)

  def get_memory(id), do: Repo.get(Memory, id)

  def get_memory_by_key(user_id, memory_type, key) do
    from(m in Memory, where: m.user_id == ^user_id and m.memory_type == ^memory_type and m.key == ^key)
    |> Repo.one()
  end

  def list_memories_for_user(user_id) do
    from(m in Memory, where: m.user_id == ^user_id, order_by: [desc: m.inserted_at])
    |> Repo.all()
  end

  def list_instructions_for_user(user_id) do
    from(m in Memory, where: m.user_id == ^user_id and m.memory_type == "instruction")
    |> Repo.all()
  end

  def create_memory(attrs \\ %{}) do
    %Memory{}
    |> Memory.changeset(attrs)
    |> Repo.insert()
  end

  def create_instruction(instruction, user_id) do
    %Memory{}
    |> Memory.instruction_changeset(instruction, user_id)
    |> Repo.insert()
  end

  def create_preference(key, value, user_id) do
    %Memory{}
    |> Memory.preference_changeset(key, value, user_id)
    |> Repo.insert()
  end

  def update_memory(%Memory{} = memory, attrs) do
    memory
    |> Memory.changeset(attrs)
    |> Repo.update()
  end

  def delete_memory(%Memory{} = memory) do
    Repo.delete(memory)
  end

  def change_memory(%Memory{} = memory, attrs \\ %{}) do
    Memory.changeset(memory, attrs)
  end

  # Utility functions
  def get_user_context(user_id) do
    instructions = list_instructions_for_user(user_id)
    preferences = from(m in Memory, where: m.user_id == ^user_id and m.memory_type == "preference")
    |> Repo.all()

    %{
      instructions: instructions,
      preferences: preferences
    }
  end

  def cleanup_expired_memories do
    from(m in Memory, where: not is_nil(m.expires_at) and m.expires_at < ^DateTime.utc_now())
    |> Repo.delete_all()
  end
end
