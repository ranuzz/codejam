defmodule CodejamWeb.OauthController do
  use CodejamWeb, :controller

  def github(conn, _params) do
    params = fetch_query_params(conn).params
    redirect(conn, to: "/organization/" <> params["state"])
  end
end
