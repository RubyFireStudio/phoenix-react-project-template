defmodule ReanixWeb.AuthErrorController do
  import Plug.Conn
  use ReanixWeb, :controller

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> render(ReanixWeb.SessionView, "wrong_credentials.json")
  end
end
