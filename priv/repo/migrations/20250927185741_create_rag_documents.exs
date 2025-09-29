defmodule FinancialAdvisorAgent.Repo.Migrations.CreateRagDocuments do
  use Ecto.Migration

  def change do
    create table(:rag_documents) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :source_type, :string, null: false
      add :source_id, :string, null: false
      add :content, :text, null: false
      add :metadata, :map, default: %{}
      add :embedding, :text
      add :processed_at, :utc_datetime

      timestamps()
    end

    create index(:rag_documents, [:user_id])
    create index(:rag_documents, [:source_type])
    create index(:rag_documents, [:source_id])
    create index(:rag_documents, [:processed_at])
    create unique_index(:rag_documents, [:user_id, :source_type, :source_id])
  end
end
