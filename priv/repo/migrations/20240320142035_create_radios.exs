defmodule Echochamber.Repo.Migrations.CreateRadios do
  use Ecto.Migration

  def change do
    create table(:radios) do
      add :name, :string
      add :url, :string
      add :description, :string
      add :genre, :string

      timestamps(type: :utc_datetime)
    end
  end
end
