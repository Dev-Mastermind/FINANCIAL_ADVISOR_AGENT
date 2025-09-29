defmodule FinancialAdvisorAgentWeb.DashboardController do
  use FinancialAdvisorAgentWeb, :controller

  alias FinancialAdvisorAgent.Accounts
  alias FinancialAdvisorAgent.Integrations
  alias FinancialAdvisorAgent.Agent

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)
    
    if user_id do
      user = Accounts.get_user!(user_id)
      integrations = Integrations.get_user_integrations(user_id)
      recent_tasks = Agent.list_tasks_for_user(user_id) |> Enum.take(5)
      instructions = Agent.list_instructions_for_user(user_id)
      
      render(conn, :index, 
        user: user, 
        integrations: integrations, 
        recent_tasks: recent_tasks,
        instructions: instructions
      )
    else
      conn
      |> put_flash(:error, "Please log in first.")
      |> redirect(to: ~p"/")
    end
  end
end
