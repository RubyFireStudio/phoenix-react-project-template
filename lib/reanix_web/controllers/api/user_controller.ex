defmodule ReanixWeb.UserController do
  use ReanixWeb, :controller

  alias Reanix.Accounts
  alias Reanix.Accounts.User

  action_fallback(ReanixWeb.FallbackController)

  def index(conn, _) do
    users = Accounts.list_users()
    current_user = Accounts.get_current_user(conn)

    render(conn, "index.json", users: users, current_user: current_user)
  end

  def show(conn, %{"username" => username}) do
    with %User{} = user <- Accounts.get_user_by_username(username) do
      current_user = Accounts.get_current_user(conn)
      render(conn, "show.json", user: user, current_user: current_user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    current_user = Accounts.get_current_user(conn)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params, current_user) do
      render(conn, "show.json", user: user)
    end
  end

  def create(conn, user_params) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      new_conn = Accounts.sign_in_user(conn, user)
      jwt = Accounts.get_current_token(new_conn)

      new_conn
      |> put_status(:created)
      |> render(ReanixWeb.SessionView, "show.json", user: user, jwt: jwt)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    current_user = Accounts.get_current_user(conn)

    with {:ok, %User{}} <- Accounts.delete_user(user, current_user) do
      send_resp(conn, :no_content, "")
    end
  end
end
