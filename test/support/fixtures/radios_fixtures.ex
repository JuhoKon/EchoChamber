defmodule Echochamber.RadiosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Echochamber.Radios` context.
  """

  @doc """
  Generate a radio.
  """
  def radio_fixture(attrs \\ %{}) do
    {:ok, radio} =
      attrs
      |> Enum.into(%{
        description: "some description",
        genre: "some genre",
        name: "some name",
        url: "some url"
      })
      |> Echochamber.Radios.create_radio()

    radio
  end
end
