defmodule CodejamWeb.OauthController do
  use CodejamWeb, :controller

  def github(conn, params) do
    case Codejam.Github.get_access_token(fetch_query_params(conn).params) do
      {:ok, %{token: token, state: organization_id}} ->
        Codejam.Accounts.create_github_integration(token, organization_id)

      {:error, _} ->
        redirect(conn, to: "/organization/" <> params["state"] <> "?success=false")
    end

    redirect(conn, to: "/organization/" <> params["state"])
  end

  def github_auth(conn, _params) do
    case Codejam.Github.get_auth_access_token(fetch_query_params(conn).params) do
      {:ok, %{token: token}} ->
        response = Codejam.Github.user_info_auth(token)

        if user = Codejam.Accounts.get_user_by_email(response["email"]) do
          conn
          |> CodejamWeb.UserAuth.log_in_oauth_user(user, %{})
        end

      {:error, _} ->
        redirect(conn, to: "/users/log_in")
    end

    redirect(conn, to: "/users/log_in")
  end
end
