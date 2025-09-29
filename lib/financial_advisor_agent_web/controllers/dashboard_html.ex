defmodule FinancialAdvisorAgentWeb.DashboardHTML do
  @moduledoc """
  This module contains pages rendered by DashboardController.

  See the `dashboard_html` directory for all templates.
  """
  use FinancialAdvisorAgentWeb, :html

  embed_templates "dashboard_html/*"
end
