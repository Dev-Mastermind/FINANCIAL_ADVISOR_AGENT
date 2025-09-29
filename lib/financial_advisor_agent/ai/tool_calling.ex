defmodule FinancialAdvisorAgent.AI.ToolCalling do
  @moduledoc """
  Tool calling system for AI agent actions.
  """

  alias FinancialAdvisorAgent.Agent
  alias FinancialAdvisorAgent.Integrations
  alias FinancialAdvisorAgent.ExternalServices.{GmailService, CalendarService, HubSpotService}

  def get_available_tools do
    [
      %{
        type: "function",
        function: %{
          name: "schedule_appointment",
          description: "Schedule an appointment with a contact",
          parameters: %{
            type: "object",
            properties: %{
              contact_name: %{type: "string", description: "Name of the contact"},
              contact_email: %{type: "string", description: "Email of the contact"},
              subject: %{type: "string", description: "Subject of the appointment"},
              description: %{type: "string", description: "Description of the appointment"},
              start_time: %{type: "string", description: "Start time in ISO format"},
              end_time: %{type: "string", description: "End time in ISO format"}
            },
            required: ["contact_name", "contact_email", "subject", "start_time", "end_time"]
          }
        }
      },
      %{
        type: "function",
        function: %{
          name: "send_email",
          description: "Send an email to a contact",
          parameters: %{
            type: "object",
            properties: %{
              to: %{type: "string", description: "Recipient email address"},
              subject: %{type: "string", description: "Email subject"},
              body: %{type: "string", description: "Email body content"}
            },
            required: ["to", "subject", "body"]
          }
        }
      },
      %{
        type: "function",
        function: %{
          name: "create_contact",
          description: "Create a new contact in HubSpot",
          parameters: %{
            type: "object",
            properties: %{
              first_name: %{type: "string", description: "First name"},
              last_name: %{type: "string", description: "Last name"},
              email: %{type: "string", description: "Email address"},
              phone: %{type: "string", description: "Phone number"},
              company: %{type: "string", description: "Company name"}
            },
            required: ["first_name", "last_name", "email"]
          }
        }
      },
      %{
        type: "function",
        function: %{
          name: "search_emails",
          description: "Search emails for specific information",
          parameters: %{
            type: "object",
            properties: %{
              query: %{type: "string", description: "Search query"},
              from: %{type: "string", description: "Sender email filter"},
              to: %{type: "string", description: "Recipient email filter"},
              date_from: %{type: "string", description: "Start date filter"},
              date_to: %{type: "string", description: "End date filter"}
            },
            required: ["query"]
          }
        }
      },
      %{
        type: "function",
        function: %{
          name: "search_calendar",
          description: "Search calendar events",
          parameters: %{
            type: "object",
            properties: %{
              query: %{type: "string", description: "Search query"},
              start_time: %{type: "string", description: "Start time filter"},
              end_time: %{type: "string", description: "End time filter"}
            },
            required: ["query"]
          }
        }
      },
      %{
        type: "function",
        function: %{
          name: "search_hubspot",
          description: "Search HubSpot contacts and notes",
          parameters: %{
            type: "object",
            properties: %{
              query: %{type: "string", description: "Search query"},
              contact_id: %{type: "string", description: "Specific contact ID to search"},
              search_type: %{type: "string", description: "Type of search: contacts, notes, or both"}
            },
            required: ["query"]
          }
        }
      }
    ]
  end

  def schedule_appointment(args, user_id) do
    # Create a task for scheduling appointment
    task_attrs = %{
      user_id: user_id,
      title: "Schedule Appointment",
      description: "Schedule appointment with #{args["contact_name"]}",
      task_type: "schedule_appointment",
      input_data: args,
      status: "pending"
    }
    
    case Agent.create_task(task_attrs) do
      {:ok, task} ->
        # Execute the scheduling
        execute_schedule_appointment(task, user_id)
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def send_email(args, user_id) do
    # Create a task for sending email
    task_attrs = %{
      user_id: user_id,
      title: "Send Email",
      description: "Send email to #{args["to"]}",
      task_type: "send_email",
      input_data: args,
      status: "pending"
    }
    
    case Agent.create_task(task_attrs) do
      {:ok, task} ->
        # Execute the email sending
        execute_send_email(task, user_id)
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def create_contact(args, user_id) do
    # Create a task for creating contact
    task_attrs = %{
      user_id: user_id,
      title: "Create Contact",
      description: "Create contact #{args["first_name"]} #{args["last_name"]}",
      task_type: "create_contact",
      input_data: args,
      status: "pending"
    }
    
    case Agent.create_task(task_attrs) do
      {:ok, task} ->
        # Execute the contact creation
        execute_create_contact(task, user_id)
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def search_emails(args, user_id) do
    # Execute email search
    case GmailService.search_emails(args, user_id) do
      {:ok, emails} ->
        {:ok, emails}
      {:error, error} ->
        {:error, error}
    end
  end

  def search_calendar(args, user_id) do
    # Execute calendar search
    case CalendarService.search_events(args, user_id) do
      {:ok, events} ->
        {:ok, events}
      {:error, error} ->
        {:error, error}
    end
  end

  def search_hubspot(args, user_id) do
    # Execute HubSpot search
    case HubSpotService.search(args, user_id) do
      {:ok, results} ->
        {:ok, results}
      {:error, error} ->
        {:error, error}
    end
  end

  defp execute_schedule_appointment(task, user_id) do
    # Get user's calendar integration
    integrations = Integrations.get_user_integrations(user_id)
    
    if integrations.calendar do
      case CalendarService.create_event(task.input_data, user_id) do
        {:ok, event} ->
          Agent.update_task_status(task, "completed", %{
            output_data: %{event: event}
          })
        {:error, error} ->
          Agent.update_task_status(task, "failed", %{
            error_message: "Failed to create calendar event: #{error}"
          })
      end
    else
      Agent.update_task_status(task, "failed", %{
        error_message: "Calendar integration not connected"
      })
    end
  end

  defp execute_send_email(task, user_id) do
    # Get user's Gmail integration
    integrations = Integrations.get_user_integrations(user_id)
    
    if integrations.gmail do
      case GmailService.send_email(task.input_data, user_id) do
        {:ok, email} ->
          Agent.update_task_status(task, "completed", %{
            output_data: %{email: email}
          })
        {:error, error} ->
          Agent.update_task_status(task, "failed", %{
            error_message: "Failed to send email: #{error}"
          })
      end
    else
      Agent.update_task_status(task, "failed", %{
        error_message: "Gmail integration not connected"
      })
    end
  end

  defp execute_create_contact(task, user_id) do
    # Get user's HubSpot integration
    integrations = Integrations.get_user_integrations(user_id)
    
    if integrations.hubspot do
      case HubSpotService.create_contact(task.input_data, user_id) do
        {:ok, contact} ->
          Agent.update_task_status(task, "completed", %{
            output_data: %{contact: contact}
          })
        {:error, error} ->
          Agent.update_task_status(task, "failed", %{
            error_message: "Failed to create contact: #{error}"
          })
      end
    else
      Agent.update_task_status(task, "failed", %{
        error_message: "HubSpot integration not connected"
      })
    end
  end
end
