defmodule FinancialAdvisorAgent.ExternalServices.MockGmailService do
  @moduledoc """
  Mock Gmail service for development environment.
  Provides fake responses that simulate real Gmail API behavior.
  """

  require Logger

  def search_emails(args, user_id) do
    Logger.info("Mock Gmail: Searching emails with args: #{inspect(args)} for user: #{user_id}")
    
    # Simulate API delay
    Process.sleep(250)
    
    query = build_mock_search_query(args)
    mock_emails = generate_mock_emails(query)
    
    {:ok, mock_emails}
  end

  def send_email(args, user_id) do
    Logger.info("Mock Gmail: Sending email with args: #{inspect(args)} for user: #{user_id}")
    
    # Simulate API delay
    Process.sleep(400)
    
    mock_response = %{
      "id" => "mock_message_#{System.unique_integer([:positive])}",
      "threadId" => "mock_thread_#{System.unique_integer([:positive])}",
      "labelIds" => ["SENT"]
    }
    
    {:ok, mock_response}
  end

  def sync_emails(user_id) do
    Logger.info("Mock Gmail: Syncing emails for user: #{user_id}")
    
    # Simulate sync delay
    Process.sleep(1200)
    
    {:ok, "Synced 8 mock emails"}
  end

  defp build_mock_search_query(args) do
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
    
    Enum.join(query_parts, " ")
  end

  defp generate_mock_emails(query) do
    base_emails = [
      %{
        "id" => "mock_email_1",
        "threadId" => "mock_thread_1",
        "subject" => "Investment Portfolio Review",
        "from" => "client1@example.com",
        "to" => "advisor@financialfirm.com",
        "date" => "Mon, 15 Jan 2024 10:30:00 -0800",
        "content" => "Hi, I'd like to schedule a review of my investment portfolio. Can we set up a meeting for next week?",
        "snippet" => "Hi, I'd like to schedule a review of my investment portfolio..."
      },
      %{
        "id" => "mock_email_2",
        "threadId" => "mock_thread_2",
        "subject" => "Tax Planning Consultation",
        "from" => "client2@example.com",
        "to" => "advisor@financialfirm.com",
        "date" => "Tue, 16 Jan 2024 14:15:00 -0800",
        "content" => "I need help with tax planning strategies for this year. What are your recommendations for maximizing deductions?",
        "snippet" => "I need help with tax planning strategies..."
      },
      %{
        "id" => "mock_email_3",
        "threadId" => "mock_thread_3",
        "subject" => "Retirement Planning Questions",
        "from" => "client3@example.com",
        "to" => "advisor@financialfirm.com",
        "date" => "Wed, 17 Jan 2024 09:45:00 -0800",
        "content" => "I'm 45 years old and want to ensure I'm on track for retirement. Can we discuss my 401k allocation and other retirement accounts?",
        "snippet" => "I'm 45 years old and want to ensure I'm on track..."
      },
      %{
        "id" => "mock_email_4",
        "threadId" => "mock_thread_4",
        "subject" => "Market Update Request",
        "from" => "advisor@financialfirm.com",
        "to" => "client1@example.com",
        "date" => "Thu, 18 Jan 2024 11:20:00 -0800",
        "content" => "Here's the market update you requested. The recent market volatility presents both challenges and opportunities for your portfolio.",
        "snippet" => "Here's the market update you requested..."
      },
      %{
        "id" => "mock_email_5",
        "threadId" => "mock_thread_5",
        "subject" => "Insurance Policy Review",
        "from" => "client4@example.com",
        "to" => "advisor@financialfirm.com",
        "date" => "Fri, 19 Jan 2024 16:30:00 -0800",
        "content" => "I'd like to review my life insurance and disability insurance policies. Are they still appropriate for my current situation?",
        "snippet" => "I'd like to review my life insurance and disability..."
      }
    ]
    
    # Filter emails based on query if provided
    if String.length(query) > 0 do
      base_emails
      |> Enum.filter(fn email ->
        email["subject"] |> String.downcase() |> String.contains?(String.downcase(query)) or
        email["content"] |> String.downcase() |> String.contains?(String.downcase(query)) or
        email["from"] |> String.downcase() |> String.contains?(String.downcase(query)) or
        email["to"] |> String.downcase() |> String.contains?(String.downcase(query))
      end)
    else
      base_emails
    end
  end
end
