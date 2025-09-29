defmodule FinancialAdvisorAgent.ExternalServices.CalendarService do
  @moduledoc """
  Google Calendar API service for calendar operations.
  """

  alias FinancialAdvisorAgent.RAG
  alias FinancialAdvisorAgent.Integrations

  def search_events(args, user_id) do
    case get_calendar_integration(user_id) do
      nil ->
        {:error, "Calendar integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Build calendar search query
        query = args["query"] || ""
        time_min = args["start_time"] || DateTime.utc_now() |> DateTime.to_iso8601()
        time_max = args["end_time"] || DateTime.utc_now() |> DateTime.add(30, :day) |> DateTime.to_iso8601()
        
        # Call Calendar API
        case call_calendar_api("https://www.googleapis.com/calendar/v3/calendars/primary/events", %{
          q: query,
          timeMin: time_min,
          timeMax: time_max,
          maxResults: 50
        }, access_token) do
          {:ok, %{"items" => events}} ->
            {:ok, events}
          {:ok, %{"items" => nil}} ->
            {:ok, []}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  def create_event(args, user_id) do
    case get_calendar_integration(user_id) do
      nil ->
        {:error, "Calendar integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Build event data
        event_data = build_event_data(args)
        
        # Create event via Calendar API
        case call_calendar_api("https://www.googleapis.com/calendar/v3/calendars/primary/events", event_data, access_token, :post) do
          {:ok, event} ->
            {:ok, event}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  def sync_events(user_id) do
    case get_calendar_integration(user_id) do
      nil ->
        {:error, "Calendar integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Get recent events
        time_min = DateTime.utc_now() |> DateTime.add(-30, :day) |> DateTime.to_iso8601()
        time_max = DateTime.utc_now() |> DateTime.add(30, :day) |> DateTime.to_iso8601()
        
        case call_calendar_api("https://www.googleapis.com/calendar/v3/calendars/primary/events", %{
          timeMin: time_min,
          timeMax: time_max,
          maxResults: 100
        }, access_token) do
          {:ok, %{"items" => events}} ->
            # Process each event
            Enum.each(events, fn event ->
              # Store in RAG
              case RAG.create_calendar_document(event, user_id) do
                {:ok, document} ->
                  # Generate embedding
                  case generate_and_store_embedding(document) do
                    {:ok, _} -> :ok
                    {:error, error} -> 
                      IO.puts("Failed to generate embedding: #{error}")
                  end
                {:error, error} ->
                  IO.puts("Failed to store event: #{error}")
              end
            end)
            
            # Update sync status
            Integrations.update_sync_status(integration, "completed")
            {:ok, "Synced #{length(events)} events"}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  defp get_calendar_integration(user_id) do
    Integrations.get_integration_by_type(user_id, "calendar")
  end

  defp build_event_data(args) do
    %{
      summary: args["subject"],
      description: args["description"] || "",
      start: %{
        dateTime: args["start_time"],
        timeZone: "UTC"
      },
      end: %{
        dateTime: args["end_time"],
        timeZone: "UTC"
      },
      attendees: [
        %{
          email: args["contact_email"],
          displayName: args["contact_name"]
        }
      ]
    }
  end

  defp call_calendar_api(url, params, access_token, method \\ :get) do
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
        {:error, "Calendar API error: #{status_code} - #{body}"}
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
