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
end
