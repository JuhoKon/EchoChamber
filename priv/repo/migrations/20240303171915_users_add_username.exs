defmodule Echochamber.Repo.Migrations.UsersAddUsername do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
    end
  end
end
