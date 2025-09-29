defmodule FinancialAdvisorAgentWeb.IntegrationsHTML do
  @moduledoc """
  This module contains pages rendered by IntegrationsController.

  See the `integrations_html` directory for all templates.
  """
  use FinancialAdvisorAgentWeb, :html

  embed_templates "integrations_html/*"
end
