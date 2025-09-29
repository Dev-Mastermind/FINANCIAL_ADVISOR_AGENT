defmodule FinancialAdvisorAgent.AI.OpenAIService do
  @moduledoc """
  OpenAI API service for chat completions and embeddings.
  """

  require Logger

  def chat_completion(prompt, opts \\ []) do
    api_key = Application.get_env(:financial_advisor_agent, :openai)[:api_key]
    
    # Validate API key is present
    if is_nil(api_key) or api_key == "mock-api-key" do
      Logger.warning("OpenAI API key not configured, falling back to mock service")
      FinancialAdvisorAgent.AI.MockOpenAIService.chat_completion(prompt, opts)
    else
      model = opts[:model] || "gpt-4"
      tools = opts[:tools] || []
      
      messages = [
        %{
          role: "system",
          content: "You are a helpful AI financial advisor assistant. You can help with scheduling, email management, and CRM tasks."
        },
        %{
          role: "user",
          content: prompt
        }
      ]
      
      request_body = %{
        model: model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 2000
      }
      
      request_body = if length(tools) > 0 do
        Map.put(request_body, :tools, tools)
      else
        request_body
      end
      
      headers = [
        {"Authorization", "Bearer #{api_key}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post("https://api.openai.com/v1/chat/completions", Jason.encode!(request_body), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          response = Jason.decode!(body)
          parse_chat_response(response)
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          Logger.error("OpenAI API error: #{status_code} - #{body}")
          {:error, "OpenAI API error: #{status_code}"}
        {:error, error} ->
          Logger.error("OpenAI request failed: #{inspect(error)}")
          {:error, "Request failed: #{inspect(error)}"}
      end
    end
  end

  def generate_embedding(text) do
    api_key = Application.get_env(:financial_advisor_agent, :openai)[:api_key]
    
    # Validate API key is present
    if is_nil(api_key) or api_key == "mock-api-key" do
      Logger.warning("OpenAI API key not configured, falling back to mock service")
      FinancialAdvisorAgent.AI.MockOpenAIService.generate_embedding(text)
    else
      request_body = %{
        model: "text-embedding-3-small",
        input: text
      }
      
      headers = [
        {"Authorization", "Bearer #{api_key}"},
        {"Content-Type", "application/json"}
      ]
      
      case HTTPoison.post("https://api.openai.com/v1/embeddings", Jason.encode!(request_body), headers) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          response = Jason.decode!(body)
          response["data"] |> List.first() |> Map.get("embedding")
        {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
          Logger.error("OpenAI Embeddings API error: #{status_code} - #{body}")
          {:error, "OpenAI Embeddings API error: #{status_code}"}
        {:error, error} ->
          Logger.error("OpenAI Embeddings request failed: #{inspect(error)}")
          {:error, "Request failed: #{inspect(error)}"}
      end
    end
  end

  defp parse_chat_response(response) do
    choice = response["choices"] |> List.first()
    message = choice["message"]
    
    %{
      response: message["content"],
      tool_calls: parse_tool_calls(message["tool_calls"]),
      usage: response["usage"]
    }
  end

  defp parse_tool_calls(nil), do: []
  defp parse_tool_calls(tool_calls) do
    Enum.map(tool_calls, fn tool_call ->
      %{
        id: tool_call["id"],
        type: tool_call["type"],
        function: %{
          name: tool_call["function"]["name"],
          arguments: Jason.decode!(tool_call["function"]["arguments"])
        }
      }
    end)
  end
end
