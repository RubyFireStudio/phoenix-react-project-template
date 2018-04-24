defmodule Reanix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Reanix.Accounts.User

  schema "users" do
    field(:name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:username, :string)
    field(:is_staff, :boolean, default: false)
    field(:is_superuser, :boolean, default: false)
    field(:last_login, :naive_datetime)

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username, :email])
    |> validate_required([:name, :username, :email])
    |> validate_length(:username, min: 1, max: 20)
    |> validate_format(:username, ~r/^[A-Za-z0-9._]+$/)
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc false
  def superuser_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:is_staff, :is_superuser])
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_password_hash
  end

  @doc false
  def superuser_registration_changeset(%User{} = user, attrs) do
    user
    |> superuser_changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_password_hash
  end

  @doc false
  def last_login_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:last_login])
    |> validate_required([:last_login])
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
