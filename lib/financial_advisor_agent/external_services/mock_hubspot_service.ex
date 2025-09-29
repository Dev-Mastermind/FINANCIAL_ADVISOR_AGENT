defmodule FinancialAdvisorAgent.ExternalServices.MockHubSpotService do
  @moduledoc """
  Mock HubSpot service for development environment.
  Provides fake responses that simulate real HubSpot API behavior.
  """

  require Logger

  def search(args, user_id) do
    Logger.info("Mock HubSpot: Searching with args: #{inspect(args)} for user: #{user_id}")
    
    # Simulate API delay
    Process.sleep(200)
    
    query = args["query"] || ""
    search_type = args["search_type"] || "both"
    
    mock_results = case search_type do
      "contacts" -> generate_mock_contacts(query)
      "notes" -> generate_mock_notes(query)
      "both" -> generate_mock_contacts(query) ++ generate_mock_notes(query)
    end
    
    {:ok, mock_results}
  end

  def create_contact(args, user_id) do
    Logger.info("Mock HubSpot: Creating contact with args: #{inspect(args)} for user: #{user_id}")
    
    # Simulate API delay
    Process.sleep(300)
    
    mock_contact = %{
      "id" => "mock_contact_#{System.unique_integer([:positive])}",
      "properties" => %{
        "firstname" => args["first_name"] || "Mock",
        "lastname" => args["last_name"] || "Contact",
        "email" => args["email"] || "mock@example.com",
        "phone" => args["phone"] || "+1-555-0123",
        "company" => args["company"] || "Mock Company"
      },
      "createdAt" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "updatedAt" => DateTime.utc_now() |> DateTime.to_iso8601()
    }
    
    {:ok, mock_contact}
  end

  def sync_contacts(user_id) do
    Logger.info("Mock HubSpot: Syncing contacts for user: #{user_id}")
    
    # Simulate sync delay
    Process.sleep(1000)
    
    {:ok, "Synced 5 mock contacts"}
  end

  def sync_notes(user_id) do
    Logger.info("Mock HubSpot: Syncing notes for user: #{user_id}")
    
    # Simulate sync delay
    Process.sleep(800)
    
    {:ok, "Synced 3 mock notes"}
  end

  defp generate_mock_contacts(query) do
    base_contacts = [
      %{
        "id" => "mock_contact_1",
        "properties" => %{
          "firstname" => "John",
          "lastname" => "Doe",
          "email" => "john.doe@example.com",
          "phone" => "+1-555-0101",
          "company" => "Acme Corp"
        },
        "createdAt" => "2024-01-10T10:00:00Z",
        "updatedAt" => "2024-01-15T14:30:00Z"
      },
      %{
        "id" => "mock_contact_2",
        "properties" => %{
          "firstname" => "Jane",
          "lastname" => "Smith",
          "email" => "jane.smith@example.com",
          "phone" => "+1-555-0102",
          "company" => "Tech Solutions Inc"
        },
        "createdAt" => "2024-01-12T09:15:00Z",
        "updatedAt" => "2024-01-16T11:45:00Z"
      },
      %{
        "id" => "mock_contact_3",
        "properties" => %{
          "firstname" => "Bob",
          "lastname" => "Johnson",
          "email" => "bob.johnson@example.com",
          "phone" => "+1-555-0103",
          "company" => "Financial Services LLC"
        },
        "createdAt" => "2024-01-14T16:20:00Z",
        "updatedAt" => "2024-01-17T08:10:00Z"
      }
    ]
    
    # Filter contacts based on query if provided
    if String.length(query) > 0 do
      base_contacts
      |> Enum.filter(fn contact ->
        contact["properties"]["firstname"] |> String.downcase() |> String.contains?(String.downcase(query)) or
        contact["properties"]["lastname"] |> String.downcase() |> String.contains?(String.downcase(query)) or
        contact["properties"]["email"] |> String.downcase() |> String.contains?(String.downcase(query)) or
        contact["properties"]["company"] |> String.downcase() |> String.contains?(String.downcase(query))
      end)
    else
      base_contacts
    end
  end

  defp generate_mock_notes(query) do
    base_notes = [
      %{
        "id" => "mock_note_1",
        "properties" => %{
          "hs_note_body" => "Initial consultation call completed. Client is interested in retirement planning services.",
          "hs_createdate" => "2024-01-10T10:00:00Z",
          "hs_created_by_user_id" => "mock_user_1"
        },
        "createdAt" => "2024-01-10T10:00:00Z",
        "updatedAt" => "2024-01-10T10:00:00Z"
      },
      %{
        "id" => "mock_note_2",
        "properties" => %{
          "hs_note_body" => "Follow-up meeting scheduled for next week. Client wants to discuss investment portfolio diversification.",
          "hs_createdate" => "2024-01-12T14:30:00Z",
          "hs_created_by_user_id" => "mock_user_1"
        },
        "createdAt" => "2024-01-12T14:30:00Z",
        "updatedAt" => "2024-01-12T14:30:00Z"
      },
      %{
        "id" => "mock_note_3",
        "properties" => %{
          "hs_note_body" => "Client expressed interest in tax optimization strategies for their business.",
          "hs_createdate" => "2024-01-15T09:45:00Z",
          "hs_created_by_user_id" => "mock_user_1"
        },
        "createdAt" => "2024-01-15T09:45:00Z",
        "updatedAt" => "2024-01-15T09:45:00Z"
      }
    ]
    
    # Filter notes based on query if provided
    if String.length(query) > 0 do
      base_notes
      |> Enum.filter(fn note ->
        note["properties"]["hs_note_body"] |> String.downcase() |> String.contains?(String.downcase(query))
      end)
    else
      base_notes
    end
  end
end
