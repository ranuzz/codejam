defmodule CodejamWeb.OauthController do
  use CodejamWeb, :controller

  def github(conn, params) do
    Codejam.Github.Oauth.get_access_token(fetch_query_params(conn).params)
    redirect(conn, to: "/organization/" <> params["state"])
  end
end
