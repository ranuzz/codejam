defmodule CodejamWeb.Router do
  use CodejamWeb, :router

  import CodejamWeb.UserAuth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {CodejamWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
    plug(:fetch_invited_memberships)
    plug(:fetch_memberships)
    plug(:fetch_active_membership)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/admin", CodejamWeb do
    pipe_through([:browser, :require_authenticated_user, :require_admin_user])
    get("/home", AdminController, :home)
  end

  scope "/oauth/callback/auth", CodejamWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])
    get("/github", OauthController, :github_auth)
  end

  scope "/oauth/callback", CodejamWeb do
    pipe_through([:browser, :require_authenticated_user])

    get("/github", OauthController, :github)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodejamWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:codejam, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: CodejamWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  ## Authentication routes

  scope "/", CodejamWeb do
    pipe_through([
      :browser,
      :redirect_home_if_user_is_admin,
      :redirect_home_if_user_is_authenticated
    ])

    get("/", PageController, :home)
  end

  scope "/", CodejamWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{CodejamWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live("/users/register", UserRegistrationLive, :new)
      live("/users/log_in", UserLoginLive, :new)
      live("/users/reset_password", UserForgotPasswordLive, :new)
      live("/users/reset_password/:token", UserResetPasswordLive, :edit)
    end

    post("/users/log_in", UserSessionController, :create)
  end

  scope "/", CodejamWeb do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{CodejamWeb.UserAuth, :ensure_authenticated}] do
      # TODO: remove user setting routes with no organization id
      # live("/users/settings", UserSettingsLive, :edit)
      # live("/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email)
      # Oboarding
      live("/organization/create", OrganizationLive.Create, :create)
      live("/organization/:id", OrganizationLive.Home, :home)
      # Settings
      live("/organization/:id/settings", UserSettingsLive, :edit)
      live("/organization/:id/confirm_email/:token", UserSettingsLive, :confirm_email)
      # Project
      live("/organization/:id/projects", ProjectLive.All, :all)
      live("/organization/:id/project/new", ProjectLive.New, :new)
      live("/organization/:id/project/:project_id", ProjectLive.Show, :show)
      # Explorer
      live(
        "/organization/:id/project/:project_id/notebook/:notebook_id",
        ExplorerLive.Show,
        :show
      )
    end
  end

  scope "/", CodejamWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{CodejamWeb.UserAuth, :mount_current_user}] do
      live("/users/confirm/:token", UserConfirmationLive, :edit)
      live("/users/confirm", UserConfirmationInstructionsLive, :new)
    end
  end
end
