defmodule ReanixWeb.PageController do
  use ReanixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
