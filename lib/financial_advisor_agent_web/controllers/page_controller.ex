defmodule FinancialAdvisorAgentWeb.PageController do
  use FinancialAdvisorAgentWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
