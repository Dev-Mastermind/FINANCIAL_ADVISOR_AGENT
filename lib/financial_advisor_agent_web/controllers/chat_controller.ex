defmodule FinancialAdvisorAgentWeb.ChatController do
  use FinancialAdvisorAgentWeb, :controller

  alias FinancialAdvisorAgent.Agent
  alias FinancialAdvisorAgent.RAG
  alias FinancialAdvisorAgent.Integrations
  alias FinancialAdvisorAgent.AI.ChatService

  def index(conn, _params) do
    # Temporarily disable authentication for testing
    user_id = get_session(conn, :user_id) || 1  # Use default user ID for testing
    
    # Get user's recent tasks and context
    tasks = Agent.list_tasks_for_user(user_id) |> Enum.take(10)
    context = Agent.get_user_context(user_id)
    
    render(conn, :index, tasks: tasks, context: context)
  end

  def create_message(conn, %{"message" => message, "conversation_id" => conversation_id}) do
    # Temporarily disable authentication for testing
    user_id = get_session(conn, :user_id) || 1  # Use default user ID for testing
    
    # Always proceed with chat functionality
    if true do
      # Create a new task for the AI agent
      task_attrs = %{
        user_id: user_id,
        title: "Chat Message",
        description: message,
        task_type: "general_instruction",
        input_data: %{
          message: message,
          conversation_id: conversation_id
        },
        status: "pending"
      }
      
      case Agent.create_task(task_attrs) do
        {:ok, task} ->
          # Process the message immediately
          case ChatService.process_message(task.id) do
            {:ok, response} ->
              json(conn, %{
                success: true,
                task_id: task.id,
                message: "Message processed successfully.",
                response: response.response
              })
            {:error, error} ->
              json(conn, %{
                success: false,
                error: "Failed to process message: #{inspect(error)}"
              })
          end
        {:error, changeset} ->
          json(conn, %{
            success: false,
            error: "Failed to create task: #{inspect(changeset.errors)}"
          })
      end
    else
      json(conn, %{
        success: false,
        error: "Please log in first."
      })
    end
  end

  def get_task_status(conn, %{"task_id" => task_id}) do
    # Temporarily disable authentication for testing
    user_id = get_session(conn, :user_id) || 1  # Use default user ID for testing
    
    # Always proceed with task status check
    if true do
      case Agent.get_task(task_id) do
        nil ->
          json(conn, %{
            success: false,
            error: "Task not found."
          })
        task ->
          if task.user_id == user_id do
            json(conn, %{
              success: true,
              task: %{
                id: task.id,
                status: task.status,
                title: task.title,
                description: task.description,
                output_data: task.output_data,
                error_message: task.error_message,
                completed_at: task.completed_at
              }
            })
          else
            json(conn, %{
              success: false,
              error: "Unauthorized."
            })
          end
      end
    else
      json(conn, %{
        success: false,
        error: "Please log in first."
      })
    end
  end

  def search_documents(conn, %{"query" => query}) do
    user_id = get_session(conn, :user_id)
    
    if user_id do
      # Search documents by content
      documents = RAG.search_documents_by_content(user_id, query)
      
      json(conn, %{
        success: true,
        documents: Enum.map(documents, fn doc ->
          %{
            id: doc.id,
            content: doc.content,
            source_type: doc.source_type,
            metadata: doc.metadata,
            inserted_at: doc.inserted_at
          }
        end)
      })
    else
      json(conn, %{
        success: false,
        error: "Please log in first."
      })
    end
  end

  def add_instruction(conn, %{"instruction" => instruction}) do
    user_id = get_session(conn, :user_id)
    
    if user_id do
      case Agent.create_instruction(instruction, user_id) do
        {:ok, _memory} ->
          json(conn, %{
            success: true,
            message: "Instruction added successfully."
          })
        {:error, changeset} ->
          json(conn, %{
            success: false,
            error: "Failed to add instruction: #{inspect(changeset.errors)}"
          })
      end
    else
      json(conn, %{
        success: false,
        error: "Please log in first."
      })
    end
  end
end
