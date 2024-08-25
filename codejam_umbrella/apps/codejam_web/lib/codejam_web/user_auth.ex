defmodule CodejamWeb.UserAuth do
  use CodejamWeb, :verified_routes

  require Logger

  import Plug.Conn
  import Phoenix.Controller

  alias Codejam.Accounts.Membership
  alias Codejam.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in UserToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_codejam_web_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the user in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_user(conn, user, params \\ %{}) do
    token = Accounts.generate_user_session_token(user)
    user_return_to = get_session(conn, :user_return_to)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  def log_in_invited_user(conn, user, _params) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> put_token_in_session(token)
    |> redirect(to: ~c"/users/reset_password")
  end

  def log_in_oauth_user(conn, user, _params) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> put_token_in_session(token)
    |> redirect(to: signed_in_path(conn))
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the user out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_user(conn) do
    user_token = get_session(conn, :user_token)
    user_token && Accounts.delete_user_session_token(user_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      CodejamWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
    |> redirect(to: ~p"/")
  end

  @doc """
  Authenticates the user by looking into the session
  and remember me token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  @doc """
  get memberships where user was invited
  """
  def fetch_invited_memberships(conn, _opts) do
    if conn.assigns[:current_user] do
      memberships = Accounts.get_user_invited_memberships(conn.assigns[:current_user])
      assign(conn, :invited_memberships, memberships)
    else
      conn
    end
  end

  @doc """
  get user memberships
  """
  def fetch_memberships(conn, _opts) do
    if conn.assigns[:current_user] do
      memberships = Accounts.get_user_memberships(conn.assigns[:current_user])
      assign(conn, :memberships, memberships)
    else
      conn
    end
  end

  @doc """
  Get active membership
  There can only be one for regular users
  take the first one if there are multiple

  This pliug must be called after fetch_current_user
  """
  def fetch_active_membership(conn, _opts) do
    if conn.assigns[:current_user] do
      membership = Accounts.get_user_active_membership(conn.assigns[:current_user])
      assign(conn, :active_membership, membership)
    else
      conn
    end
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.

  ## `on_mount` arguments

    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.

    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.

    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.

  ## Examples

  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:

      defmodule CodejamWeb.PageLive do
        use CodejamWeb, :live_view

        on_mount {CodejamWeb.UserAuth, :mount_current_user}
        ...
      end

  Or use the `live_session` of your router to invoke the on_mount callback:

      live_session :authenticated, on_mount: [{CodejamWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)
    socket = mount_active_membership(socket, session)

    if socket.assigns.current_user && socket.assigns.active_membership do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/users/log_in")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)
    socket = mount_active_membership(socket, session)

    if socket.assigns.current_user && socket.assigns.active_membership do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        Accounts.get_user_by_session_token(user_token)
      end
    end)
  end

  defp mount_active_membership(socket, _session) do
    Phoenix.Component.assign_new(socket, :active_membership, fn ->
      if socket.assigns.current_user do
        Accounts.get_user_active_membership(socket.assigns.current_user)
      end
    end)
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  @doc """
  check if user is an admin
  """
  def require_admin_user(conn, _opts) do
    if conn.assigns[:current_user] &&
         Map.has_key?(conn.assigns[:current_user], :role) &&
         conn.assigns[:current_user].role == "admin" do
      conn
    else
      conn
      |> put_flash(:error, "Path does not exists.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  @doc """
  check if user is an admin and redirect to admin home
  """
  def redirect_home_if_user_is_admin(conn, _opts) do
    if conn.assigns[:current_user] &&
         Map.has_key?(conn.assigns[:current_user], :role) &&
         conn.assigns[:current_user].role == "admin" do
      conn
      |> redirect(to: ~p"/admin/home")
      |> halt()
    else
      conn
    end
  end

  @doc """
  check if user is authenticated
  * Redirect to organization home if is member of an organization
  * Redirect to organization selection page is part of multiple organization
  * Update membership and redirect to organization home if invited user email
  * Else: prompt to create an organization
  """
  def redirect_home_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] &&
         Map.has_key?(conn.assigns[:current_user], :role) &&
         conn.assigns[:current_user].role == "user" do
      invited_memberships = conn.assigns[:invited_memberships]
      active_membership = conn.assigns[:active_membership]

      if active_membership do
        conn
        |> redirect(to: "/home")
        |> halt()
      end

      if Kernel.length(invited_memberships) !== 0 do
        first_invitation = hd(invited_memberships)

        Membership.update_user_id(first_invitation, %{"user_id" => conn.assigns[:current_user].id})

        conn
        |> redirect(to: ~p"/")
        |> halt()
      end

      if Kernel.length(invited_memberships) === 0 do
        conn
        |> redirect(to: ~p"/organization/create")
        |> halt()
      end
    else
      conn
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
