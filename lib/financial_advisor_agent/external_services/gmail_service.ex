defmodule FinancialAdvisorAgent.ExternalServices.GmailService do
  @moduledoc """
  Gmail API service for email operations.
  """

  alias FinancialAdvisorAgent.Accounts
  alias FinancialAdvisorAgent.RAG
  alias FinancialAdvisorAgent.Integrations

  def search_emails(args, user_id) do
    case get_gmail_integration(user_id) do
      nil ->
        {:error, "Gmail integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Build Gmail search query
        query = build_search_query(args)
        
        # Call Gmail API
        case call_gmail_api("https://gmail.googleapis.com/gmail/v1/users/me/messages", %{
          q: query,
          maxResults: 50
        }, access_token) do
          {:ok, %{"messages" => messages}} ->
            # Get full message details
            emails = Enum.map(messages, fn message ->
              get_message_details(message["id"], access_token)
            end)
            |> Enum.filter(fn email -> email != nil end)
            
            {:ok, emails}
          {:ok, %{"messages" => nil}} ->
            {:ok, []}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  def send_email(args, user_id) do
    case get_gmail_integration(user_id) do
      nil ->
        {:error, "Gmail integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Build email message
        message = build_email_message(args)
        
        # Send email via Gmail API
        case call_gmail_api("https://gmail.googleapis.com/gmail/v1/users/me/messages/send", %{
          raw: message
        }, access_token, :post) do
          {:ok, response} ->
            {:ok, response}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  def sync_emails(user_id) do
    case get_gmail_integration(user_id) do
      nil ->
        {:error, "Gmail integration not connected"}
      integration ->
        access_token = integration.config["access_token"]
        
        # Get recent emails
        case call_gmail_api("https://gmail.googleapis.com/gmail/v1/users/me/messages", %{
          q: "newer_than:1d",
          maxResults: 100
        }, access_token) do
          {:ok, %{"messages" => messages}} ->
            # Process each email
            Enum.each(messages, fn message ->
              case get_message_details(message["id"], access_token) do
                nil -> :ok
                email_data ->
                  # Store in RAG
                  case RAG.create_email_document(email_data, user_id) do
                    {:ok, document} ->
                      # Generate embedding
                      case generate_and_store_embedding(document) do
                        {:ok, _} -> :ok
                        {:error, error} -> 
                          IO.puts("Failed to generate embedding: #{error}")
                      end
                    {:error, error} ->
                      IO.puts("Failed to store email: #{error}")
                  end
              end
            end)
            
            # Update sync status
            Integrations.update_sync_status(integration, "completed")
            {:ok, "Synced #{length(messages)} emails"}
          {:error, error} ->
            {:error, error}
        end
    end
  end

  defp get_gmail_integration(user_id) do
    Integrations.get_integration_by_type(user_id, "gmail")
  end

  defp build_search_query(args) do
    query_parts = []
    
    query_parts = if args["query"] do
      ["#{args["query"]}"] ++ query_parts
    else
      query_parts
    end
    
    query_parts = if args["from"] do
      ["from:#{args["from"]}"] ++ query_parts
    else
      query_parts
    end
    
    query_parts = if args["to"] do
      ["to:#{args["to"]}"] ++ query_parts
    else
      query_parts
    end
    
    query_parts = if args["date_from"] do
      ["after:#{args["date_from"]}"] ++ query_parts
    else
      query_parts
    end
    
    query_parts = if args["date_to"] do
      ["before:#{args["date_to"]}"] ++ query_parts
    else
      query_parts
    end
    
    Enum.join(query_parts, " ")
  end

  defp build_email_message(args) do
    # Build RFC 2822 email message
    message = """
    To: #{args["to"]}
    Subject: #{args["subject"]}
    Content-Type: text/html; charset=UTF-8
    
    #{args["body"]}
    """
    
    # Base64 encode
    Base.encode64(message)
  end

  defp get_message_details(message_id, access_token) do
    case call_gmail_api("https://gmail.googleapis.com/gmail/v1/users/me/messages/#{message_id}", %{}, access_token) do
      {:ok, message} ->
        # Parse message data
        headers = message["payload"]["headers"] || []
        
        subject = headers
        |> Enum.find(fn h -> h["name"] == "Subject" end)
        |> case do
          nil -> ""
          header -> header["value"]
        end
        
        from = headers
        |> Enum.find(fn h -> h["name"] == "From" end)
        |> case do
          nil -> ""
          header -> header["value"]
        end
        
        to = headers
        |> Enum.find(fn h -> h["name"] == "To" end)
        |> case do
          nil -> ""
          header -> header["value"]
        end
        
        date = headers
        |> Enum.find(fn h -> h["name"] == "Date" end)
        |> case do
          nil -> ""
          header -> header["value"]
        end
        
        # Get message body
        body = extract_message_body(message["payload"])
        
        %{
          id: message_id,
          subject: subject,
          from: from,
          to: to,
          date: date,
          content: body,
          thread_id: message["threadId"]
        }
      {:error, _error} ->
        nil
    end
  end

  defp extract_message_body(payload) do
    case payload["body"]["data"] do
      nil ->
        # Check for parts
        case payload["parts"] do
          nil -> ""
          parts ->
            parts
            |> Enum.map(fn part -> extract_message_body(part) end)
            |> Enum.join(" ")
        end
      data ->
        Base.decode64!(data)
    end
  end

  defp call_gmail_api(url, params, access_token, method \\ :get) do
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
        {:error, "Gmail API error: #{status_code} - #{body}"}
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
