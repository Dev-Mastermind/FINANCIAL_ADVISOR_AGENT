defmodule FinancialAdvisorAgentWeb.ChatHTML do
  @moduledoc """
  This module contains pages rendered by ChatController.

  See the `chat_html` directory for all templates.
  """
  use FinancialAdvisorAgentWeb, :html

  embed_templates "chat_html/*"
end
