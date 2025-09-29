defmodule FinancialAdvisorAgentWeb.Router do
  use FinancialAdvisorAgentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FinancialAdvisorAgentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Ueberauth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FinancialAdvisorAgentWeb do
    pipe_through :browser

    get "/", PageController, :home
    
    # Authentication routes
    get "/auth/logout", AuthController, :logout
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/:provider/callback", AuthController, :callback
    
    # Dashboard routes
    get "/dashboard", DashboardController, :index
    
    # Chat routes
    get "/chat", ChatController, :index
    post "/chat/message", ChatController, :create_message
    get "/chat/task/:task_id", ChatController, :get_task_status
    post "/chat/search", ChatController, :search_documents
    post "/chat/instruction", ChatController, :add_instruction
    
    # Integrations routes
    get "/integrations", IntegrationsController, :index
    get "/integrations/sync", IntegrationsController, :sync_data
    
    # HubSpot routes
    get "/hubspot/connect", HubspotController, :connect
    get "/hubspot/callback", HubspotController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", FinancialAdvisorAgentWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:financial_advisor_agent, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FinancialAdvisorAgentWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end