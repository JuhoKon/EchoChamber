defmodule Echochamber.Radios.Radio do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:name, :description, :genre], sortable: [:name, :description, :genre], default_limit: 6
  }

  schema "radios" do
    field :name, :string
    field :description, :string
    field :url, :string
    field :genre, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(radio, attrs) do
    radio
    |> cast(attrs, [:name, :url, :description, :genre])
    |> validate_required([:name, :url, :description, :genre])
  end
end
