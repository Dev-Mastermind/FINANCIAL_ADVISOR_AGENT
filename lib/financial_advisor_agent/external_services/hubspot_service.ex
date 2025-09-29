defmodule FinancialAdvisorAgent.ExternalServices.HubSpotService do
  @moduledoc """
  HubSpot API service for CRM operations.
  """

  alias FinancialAdvisorAgent.RAG
  alias FinancialAdvisorAgent.Integrations

  def search(args, user_id) do
    case get_hubspot_integration(user_id) do
      nil ->
        {:error, "HubSpot integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        _portal_id = integration.config["portal_id"]
        
        # Build search query
        query = args["query"] || ""
        search_type = args["search_type"] || "both"
        
        results = case search_type do
          "contacts" -> search_contacts(query, access_token)
          "notes" -> search_notes(query, access_token)
          "both" -> 
            contacts = search_contacts(query, access_token)
            notes = search_notes(query, access_token)
            contacts ++ notes
        end
        
        {:ok, results}
    end
  end

  def create_contact(args, user_id) do
    case get_hubspot_integration(user_id) do
      nil ->
        {:error, "HubSpot integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Build contact data
        contact_data = build_contact_data(args)
        
        # Create contact via HubSpot API
        case call_hubspot_api("https://api.hubapi.com/crm/v3/objects/contacts", contact_data, access_token, :post) do
          {:ok, contact} ->
            {:ok, contact}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  def sync_contacts(user_id) do
    case get_hubspot_integration(user_id) do
      nil ->
        {:error, "HubSpot integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Get recent contacts
        case call_hubspot_api("https://api.hubapi.com/crm/v3/objects/contacts", %{
          limit: 100,
          properties: "firstname,lastname,email,phone,company"
        }, access_token) do
          {:ok, %{"results" => contacts}} ->
            # Process each contact
            Enum.each(contacts, fn contact ->
              # Store in RAG
              case RAG.create_hubspot_contact_document(contact, user_id) do
                {:ok, document} ->
                  # Generate embedding
                  case generate_and_store_embedding(document) do
                    {:ok, _} -> :ok
                    {:error, error} -> 
                      IO.puts("Failed to generate embedding: #{error}")
                  end
                {:error, error} ->
                  IO.puts("Failed to store contact: #{error}")
              end
            end)
            
            # Update sync status
            Integrations.update_sync_status(integration, "completed")
            {:ok, "Synced #{length(contacts)} contacts"}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  def sync_notes(user_id) do
    case get_hubspot_integration(user_id) do
      nil ->
        {:error, "HubSpot integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Get recent notes
        case call_hubspot_api("https://api.hubapi.com/crm/v3/objects/notes", %{
          limit: 100,
          properties: "hs_note_body,hs_createdate,hs_created_by_user_id"
        }, access_token) do
          {:ok, %{"results" => notes}} ->
            # Process each note
            Enum.each(notes, fn note ->
              # Store in RAG
              case RAG.create_hubspot_note_document(note, user_id) do
                {:ok, document} ->
                  # Generate embedding
                  case generate_and_store_embedding(document) do
                    {:ok, _} -> :ok
                    {:error, error} -> 
                      IO.puts("Failed to generate embedding: #{error}")
                  end
                {:error, error} ->
                  IO.puts("Failed to store note: #{error}")
              end
            end)
            
            # Update sync status
            Integrations.update_sync_status(integration, "completed")
            {:ok, "Synced #{length(notes)} notes"}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  defp get_hubspot_integration(user_id) do
    Integrations.get_integration_by_type(user_id, "hubspot")
  end

  defp build_contact_data(args) do
    %{
      properties: %{
        firstname: args["first_name"],
        lastname: args["last_name"],
        email: args["email"],
        phone: args["phone"] || "",
        company: args["company"] || ""
      }
    }
  end

  defp search_contacts(query, access_token) do
    case call_hubspot_api("https://api.hubapi.com/crm/v3/objects/contacts/search", %{
      query: query,
      limit: 50,
      properties: "firstname,lastname,email,phone,company"
    }, access_token, :post) do
      {:ok, %{"results" => contacts}} -> contacts
      {:error, _error} -> []
    end
  end

  defp search_notes(query, access_token) do
    case call_hubspot_api("https://api.hubapi.com/crm/v3/objects/notes/search", %{
      query: query,
      limit: 50,
      properties: "hs_note_body,hs_createdate,hs_created_by_user_id"
    }, access_token, :post) do
      {:ok, %{"results" => notes}} -> notes
      {:error, _error} -> []
    end
  end

  defp call_hubspot_api(url, params, access_token, method \\ :get) do
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]
    
    case method do
      :get ->
        query_string = URI.encode_query(params)
        full_url = "#{url}?#{query_string}"
        HTTPoison.get(full_url, headers)
      :post ->
        HTTPoison.post(url, Jason.encode!(params), headers)
    end
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "HubSpot API error: #{status_code} - #{body}"}
      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp generate_and_store_embedding(document) do
    # Generate embedding for the document content
    case FinancialAdvisorAgent.AI.OpenAIService.generate_embedding(document.content) do
      {:ok, embedding} ->
        RAG.update_document_embedding(document, embedding)
      {:error, error} ->
        {:error, error}
    end
  end
end
