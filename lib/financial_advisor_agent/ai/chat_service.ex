defmodule FinancialAdvisorAgent.AI.ChatService do
  @moduledoc """
  AI Chat Service for processing messages and generating responses.
  """

  alias FinancialAdvisorAgent.Agent
  alias FinancialAdvisorAgent.RAG
  alias FinancialAdvisorAgent.Integrations
  alias FinancialAdvisorAgent.AI.OpenAIService
  alias FinancialAdvisorAgent.AI.ToolCalling

  def process_message(task_id) do
    case Agent.get_task(task_id) do
      nil ->
        {:error, "Task not found"}
      task ->
        # Update task status to in_progress
        Agent.update_task_status(task, "in_progress")
        
        try do
          # Get user context and RAG documents
          user_context = Agent.get_user_context(task.user_id)
          integrations = Integrations.get_user_integrations(task.user_id)
          
          # Generate embedding for the query
          # query_embedding = OpenAIService.generate_embedding(task.input_data["message"])
          
          # Get relevant documents - temporarily disabled due to vector column issues
          # rag_context = RAG.get_documents_for_rag(task.user_id, query_embedding)
          rag_context = %{context: []}  # Empty context for now
          
          # Process the message with AI
          response = process_with_ai(task, user_context, rag_context, integrations)
          
          # Update task with response
          Agent.update_task_status(task, "completed", %{
            output_data: %{
              response: response.response,
              tool_calls: response.tool_calls,
              context_used: rag_context.context
            }
          })
          
          # Execute any tool calls
          if response.tool_calls && length(response.tool_calls) > 0 do
            execute_tool_calls(response.tool_calls, task.user_id)
          end
          
          {:ok, response}
        rescue
          error ->
            Agent.update_task_status(task, "failed", %{
              error_message: "Error processing message: #{inspect(error)}"
            })
            {:error, error}
        end
    end
  end

  defp process_with_ai(task, user_context, rag_context, integrations) do
    # Build the prompt with context
    prompt = build_prompt(task.input_data["message"], user_context, rag_context, integrations)
    
    # Call OpenAI API
    OpenAIService.chat_completion(prompt, tools: ToolCalling.get_available_tools())
  end

  defp build_prompt(message, user_context, rag_context, integrations) do
    instructions = user_context.instructions
    |> Enum.map(fn instruction -> instruction.value end)
    |> Enum.join("\n")
    
    preferences = user_context.preferences
    |> Enum.map(fn pref -> "#{pref.key}: #{pref.value}" end)
    |> Enum.join("\n")
    
    rag_context_text = rag_context.context
    |> Enum.map(fn doc -> "#{doc.source_type}: #{doc.content}" end)
    |> Enum.join("\n")
    
    """
    You are an AI financial advisor assistant. You have access to the user's email, calendar, and HubSpot CRM data.
    
    User Instructions:
    #{instructions}
    
    User Preferences:
    #{preferences}
    
    Available Data Context:
    #{rag_context_text}
    
    Available Integrations:
    - Gmail: #{if integrations.gmail, do: "Connected", else: "Not connected"}
    - Calendar: #{if integrations.calendar, do: "Connected", else: "Not connected"}
    - HubSpot: #{if integrations.hubspot, do: "Connected", else: "Not connected"}
    
    User Message: #{message}
    
    Please respond to the user's message. If you need to perform actions, use the available tools.
    Be helpful, professional, and use the context provided to give accurate responses.
    """
  end

  defp execute_tool_calls(tool_calls, user_id) do
    Enum.each(tool_calls, fn tool_call ->
      case tool_call.function do
        "schedule_appointment" ->
          ToolCalling.schedule_appointment(tool_call.arguments, user_id)
        "send_email" ->
          ToolCalling.send_email(tool_call.arguments, user_id)
        "create_contact" ->
          ToolCalling.create_contact(tool_call.arguments, user_id)
        "search_emails" ->
          ToolCalling.search_emails(tool_call.arguments, user_id)
        "search_calendar" ->
          ToolCalling.search_calendar(tool_call.arguments, user_id)
        "search_hubspot" ->
          ToolCalling.search_hubspot(tool_call.arguments, user_id)
        _ ->
          {:error, "Unknown tool: #{tool_call.function}"}
      end
    end)
  end
end
