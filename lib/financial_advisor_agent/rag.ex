defmodule FinancialAdvisorAgent.RAG do
  @moduledoc """
  The RAG (Retrieval-Augmented Generation) context for managing documents and embeddings.
  """

  import Ecto.Query, warn: false
  alias FinancialAdvisorAgent.Repo
  alias FinancialAdvisorAgent.RAG.Document

  def get_document!(id), do: Repo.get!(Document, id)

  def get_document(id), do: Repo.get(Document, id)

  def list_documents_for_user(user_id) do
    from(d in Document, where: d.user_id == ^user_id, order_by: [desc: d.inserted_at])
    |> Repo.all()
  end

  def list_documents_by_type(user_id, source_type) do
    from(d in Document, where: d.user_id == ^user_id and d.source_type == ^source_type)
    |> Repo.all()
  end

  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  def create_email_document(email_data, user_id) do
    %Document{}
    |> Document.email_changeset(email_data, user_id)
    |> Repo.insert()
  end

  def create_calendar_document(event_data, user_id) do
    %Document{}
    |> Document.calendar_changeset(event_data, user_id)
    |> Repo.insert()
  end

  def create_hubspot_contact_document(contact_data, user_id) do
    %Document{}
    |> Document.hubspot_contact_changeset(contact_data, user_id)
    |> Repo.insert()
  end

  def create_hubspot_note_document(note_data, user_id) do
    %Document{}
    |> Document.hubspot_note_changeset(note_data, user_id)
    |> Repo.insert()
  end

  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  def update_document_embedding(%Document{} = document, embedding) do
    document
    |> Document.changeset(%{embedding: embedding, processed_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  def search_similar_documents(user_id, query_embedding, limit \\ 10) do
    from(d in Document,
      where: d.user_id == ^user_id and not is_nil(d.embedding),
      order_by: fragment("embedding <-> ?", ^query_embedding),
      limit: ^limit
    )
    |> Repo.all()
  end

  def search_documents_by_content(user_id, search_term) do
    from(d in Document,
      where: d.user_id == ^user_id and ilike(d.content, ^"%#{search_term}%"),
      order_by: [desc: d.inserted_at]
    )
    |> Repo.all()
  end

  def get_documents_for_rag(user_id, query_embedding, limit \\ 5) do
    similar_docs = search_similar_documents(user_id, query_embedding, limit)
    
    # Combine content from similar documents
    context = similar_docs
    |> Enum.map(fn doc ->
      %{
        content: doc.content,
        metadata: doc.metadata,
        source_type: doc.source_type,
        source_id: doc.source_id
      }
    end)

    %{
      documents: similar_docs,
      context: context
    }
  end

  def cleanup_old_documents(days_old \\ 30) do
    cutoff_date = DateTime.utc_now() |> DateTime.add(-days_old, :day)
    
    from(d in Document, where: d.inserted_at < ^cutoff_date)
    |> Repo.delete_all()
  end
end
