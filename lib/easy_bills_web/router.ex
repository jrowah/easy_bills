defmodule EasyBillsWeb.Router do
  use EasyBillsWeb, :router

  import EasyBillsWeb.UserAuth

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

  ## Authentication routes

  scope "/", EasyBillsWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{EasyBillsWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/register", UserRegistrationLive, :new
      live "/login", UserLoginLive, :new
      live "/reset_password", UserForgotPasswordLive, :new
      live "/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/login", UserSessionController, :create
  end

  scope "/", EasyBillsWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{EasyBillsWeb.UserAuth, :ensure_authenticated}] do
      live "/settings", UserSettingsLive, :edit_bio
      live "/settings/edit_password", UserSettingsLive, :edit_password
      live "/settings/edit_email_notifications", UserSettingsLive, :edit_email_notifications
      live "/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/welcome", UserWelcomeLive
      live "/address", UserAddressLive
      live "/invoices", InvoicesLive
    end
  end

  scope "/", EasyBillsWeb do
    pipe_through [:browser]

    delete "/logout", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{EasyBillsWeb.UserAuth, :mount_current_user}] do
      live "/confirm/:token", UserConfirmationLive, :edit
      live "/confirm", UserConfirmationInstructionsLive, :new
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
