defmodule EasyBillsWeb.Router do
  use EasyBillsWeb, :router

  import EasyBillsWeb.Hooks.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EasyBillsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EasyBillsWeb do
    pipe_through :browser

    scope "/", Landing do
      live "/", LandingLive, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", EasyBillsWeb do
  #   pipe_through :api
  # end

  # Authentication routes
  scope "/auth", EasyBillsWeb do
    pipe_through :browser

    post "/login", SessionController, :create

    delete "/logout", SessionController, :delete
  end

  scope "/access", EasyBillsWeb.Access do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{EasyBillsWeb.Hooks.UserAuth, :mount_current_user}] do
      live "/confirm/:token", ConfirmationLive, :edit
      live "/confirm", ConfirmationInstructionsLive, :new
    end

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{EasyBillsWeb.Hooks.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", RegistrationLive, :new
      live "/login", LoginLive, :new
      live "/reset_password", ForgotPasswordLive, :new
      live "/reset_password/:token", ResetPasswordLive, :edit
    end
  end

  scope "/dashboard", EasyBillsWeb.Dashboard do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        # {EasyBillsWeb.Hooks.UserAuth, :ensure_authenticated},
        EasyBillsWeb.Dashboard.Hooks.Session
      ],
      root_layout: {EasyBillsWeb.Layouts, :dashboard},
      layout: {EasyBillsWeb.Layouts, :dashboard_live} do
      live "/", Home.IndexLive, :index
      live "/invoices", Invoices.IndexLive, :index
      live "/invoices/new", InvoiceLive.Index, :new
      live "/invoices/:id/edit", InvoiceLive.Index, :edit

      live "/invoices/:id", InvoiceLive.Show, :show
      live "/invoices/:id/show/edit", InvoiceLive.Show, :edit

      live "/expenses", Expenses.IndexLive, :index

      live "/settings", Settings.IndexLive, :edit_bio
      live "/settings/edit_password", Settings.IndexLive, :edit_password
      live "/settings/edit_email_notifications", Settings.IndexLive, :edit_email_notifications
      live "/settings/confirm_email/:token", Settings.IndexLive, :confirm_email
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:easy_bills, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    if Mix.env() == :dev do
      scope "/dev" do
        pipe_through :browser

        live_dashboard "/dashboard", metrics: EasyBillsWeb.Telemetry
        forward "/mailbox", Plug.Swoosh.MailboxPreview
      end
    end
  end
end
