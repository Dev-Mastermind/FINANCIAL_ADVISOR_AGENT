defmodule FinancialAdvisorAgent.RAG.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rag_documents" do
    field :source_type, :string
    field :source_id, :string
    field :content, :string
    field :metadata, :map, default: %{}
    field :embedding, Pgvector.Ecto.Vector
    field :processed_at, :utc_datetime

    belongs_to :user, FinancialAdvisorAgent.Accounts.User

    timestamps()
  end

  def changeset(document, attrs) do
    document
    |> cast(attrs, [
      :source_type, :source_id, :content, :metadata, :embedding, :processed_at, :user_id
    ])
    |> validate_required([:source_type, :source_id, :content, :user_id])
    |> validate_inclusion(:source_type, ["email", "calendar", "hubspot_contact", "hubspot_note"])
    |> unique_constraint([:user_id, :source_type, :source_id])
    |> foreign_key_constraint(:user_id)
  end

  def email_changeset(document, email_data, user_id) do
    changeset(document, %{
      source_type: "email",
      source_id: email_data.id,
      content: email_data.content,
      metadata: %{
        subject: email_data.subject,
        from: email_data.from,
        to: email_data.to,
        date: email_data.date,
        thread_id: email_data.thread_id
      },
      user_id: user_id
    })
  end

  def calendar_changeset(document, event_data, user_id) do
    changeset(document, %{
      source_type: "calendar",
      source_id: event_data.id,
      content: "#{event_data.summary}: #{event_data.description || ""}",
      metadata: %{
        summary: event_data.summary,
        description: event_data.description,
        start_time: event_data.start_time,
        end_time: event_data.end_time,
        attendees: event_data.attendees
      },
      user_id: user_id
    })
  end

  def hubspot_contact_changeset(document, contact_data, user_id) do
    changeset(document, %{
      source_type: "hubspot_contact",
      source_id: contact_data.id,
      content: "#{contact_data.first_name} #{contact_data.last_name} - #{contact_data.email}",
      metadata: %{
        first_name: contact_data.first_name,
        last_name: contact_data.last_name,
        email: contact_data.email,
        phone: contact_data.phone,
        company: contact_data.company,
        properties: contact_data.properties
      },
      user_id: user_id
    })
  end

  def hubspot_note_changeset(document, note_data, user_id) do
    changeset(document, %{
      source_type: "hubspot_note",
      source_id: note_data.id,
      content: note_data.body,
      metadata: %{
        contact_id: note_data.contact_id,
        created_by: note_data.created_by,
        created_at: note_data.created_at
      },
      user_id: user_id
    })
  end
end
