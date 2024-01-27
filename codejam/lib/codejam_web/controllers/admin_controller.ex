defmodule CodejamWeb.AdminController do
  use CodejamWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
