defmodule FinancialAdvisorAgent.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias FinancialAdvisorAgent.Repo
  alias FinancialAdvisorAgent.Accounts.User

  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_google_uid(google_uid) do
    Repo.get_by(User, google_uid: google_uid)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_google_tokens(%User{} = user, attrs) do
    user
    |> User.google_changeset(attrs)
    |> Repo.update()
  end

  def update_hubspot_tokens(%User{} = user, attrs) do
    user
    |> User.hubspot_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def list_users do
    Repo.all(User)
  end

  def list_active_users do
    from(u in User, where: u.is_active == true)
    |> Repo.all()
  end
end
