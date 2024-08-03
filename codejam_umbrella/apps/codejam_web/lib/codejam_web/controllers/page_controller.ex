defmodule CodejamWeb.PageController do
  use CodejamWeb, :controller

  def home(conn, _params) do
    render(conn, :landing)
  end
end
