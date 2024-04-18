defmodule PlotyWeb.Router do
  use PlotyWeb, :router

  import PlotyWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PlotyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlotyWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlotyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ploty, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PlotyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PlotyWeb do
    pipe_through [:browser]

    live_session :redirect_if_user_is_authenticated,
      layout: false,
      on_mount: [{PlotyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", Auth.UserRegistrationLive, :new
      live "/users/log_in", Auth.UserLoginLive, :new
      live "/users/reset_password", Auth.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", Auth.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", PlotyWeb do
    pipe_through [:browser]

    live_session :require_authenticated_user,
      on_mount: [{PlotyWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", Auth.UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", Auth.UserSettingsLive, :confirm_email

      scope "/plots", PlotLive do
        live "/", Index, :index
        live "/new", Index, :new
        live "/:id/edit", Index, :edit

        live "/:id", Show, :show
        live "/:id/show/edit", Show, :edit
      end
    end
  end

  scope "/", PlotyWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{PlotyWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", Auth.UserConfirmationLive, :edit
      live "/users/confirm", Auth.UserConfirmationInstructionsLive, :new
    end
  end
end
