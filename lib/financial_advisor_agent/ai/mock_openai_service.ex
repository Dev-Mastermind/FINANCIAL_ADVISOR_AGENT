defmodule FinancialAdvisorAgent.AI.MockOpenAIService do
  @moduledoc """
  Mock OpenAI service for development environment.
  Provides fake responses that simulate real OpenAI API behavior.
  """

  require Logger

  def chat_completion(prompt, opts \\ []) do
    Logger.info("Mock OpenAI: Processing chat completion with prompt: #{String.slice(prompt, 0, 100)}...")
    
    # Simulate processing delay
    Process.sleep(100)
    
    # Generate a mock response based on the prompt
    mock_response = generate_mock_response(prompt, opts)
    
    {:ok, mock_response}
  end

  def generate_embedding(text) do
    Logger.info("Mock OpenAI: Generating embedding for text: #{String.slice(text, 0, 50)}...")
    
    # Simulate processing delay
    Process.sleep(50)
    
    # Generate a mock embedding (1536 dimensions for text-embedding-3-small)
    mock_embedding = generate_mock_embedding()
    
    {:ok, mock_embedding}
  end

  defp generate_mock_response(prompt, opts) do
    _model = opts[:model] || "gpt-4"
    tools = opts[:tools] || []
    
    # Generate contextual mock responses
    response_content = cond do
      String.contains?(String.downcase(prompt), "schedule") or String.contains?(String.downcase(prompt), "meeting") ->
        "I'd be happy to help you schedule a meeting. Based on your request, I can see you're looking to set up a consultation. Let me check your calendar and suggest some available times."
      
      String.contains?(String.downcase(prompt), "email") or String.contains?(String.downcase(prompt), "send") ->
        "I can help you draft and send that email. I'll make sure it's professional and includes all the necessary details for your client communication."
      
      String.contains?(String.downcase(prompt), "contact") or String.contains?(String.downcase(prompt), "crm") ->
        "I found several contacts in your CRM that match your criteria. Let me pull up the relevant information and help you with your contact management needs."
      
      String.contains?(String.downcase(prompt), "financial") or String.contains?(String.downcase(prompt), "investment") ->
        "As your financial advisor, I can help you with investment strategies, portfolio analysis, and financial planning. Let me provide some personalized recommendations based on your goals."
      
      true ->
        "I'm here to help you with your financial advisory needs. I can assist with scheduling, email management, CRM tasks, and financial planning. What would you like me to help you with today?"
    end
    
    # Simulate tool calls if tools are provided
    tool_calls = if length(tools) > 0 do
      generate_mock_tool_calls(tools)
    else
      []
    end
    
    %{
      response: response_content,
      tool_calls: tool_calls,
      usage: %{
        "prompt_tokens" => String.length(prompt) / 4,
        "completion_tokens" => String.length(response_content) / 4,
        "total_tokens" => (String.length(prompt) + String.length(response_content)) / 4
      }
    }
  end

  defp generate_mock_tool_calls(tools) do
    # Randomly select a tool to "call"
    selected_tool = Enum.random(tools)
    
    case selected_tool["function"]["name"] do
      "search_hubspot" ->
        [%{
          id: "call_#{System.unique_integer([:positive])}",
          type: "function",
          function: %{
            name: "search_hubspot",
            arguments: %{
              "query" => "mock search query",
              "search_type" => "contacts"
            }
          }
        }]
      
      "send_email" ->
        [%{
          id: "call_#{System.unique_integer([:positive])}",
          type: "function",
          function: %{
            name: "send_email",
            arguments: %{
              "to" => "client@example.com",
              "subject" => "Mock Email Subject",
              "body" => "This is a mock email body."
            }
          }
        }]
      
      "schedule_meeting" ->
        [%{
          id: "call_#{System.unique_integer([:positive])}",
          type: "function",
          function: %{
            name: "schedule_meeting",
            arguments: %{
              "title" => "Mock Meeting",
              "date" => "2024-01-15",
              "time" => "10:00 AM",
              "duration" => "60 minutes"
            }
          }
        }]
      
      _ ->
        []
    end
  end

  defp generate_mock_embedding do
    # Generate a mock embedding vector (1536 dimensions)
    for _i <- 1..1536 do
      :rand.uniform() * 2 - 1  # Random float between -1 and 1
    end
  end
end
