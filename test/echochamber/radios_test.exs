defmodule Echochamber.RadiosTest do
  use Echochamber.DataCase

  alias Echochamber.Radios

  describe "radios" do
    alias Echochamber.Radios.Radio

    import Echochamber.RadiosFixtures

    @invalid_attrs %{name: nil, description: nil, url: nil, genre: nil}

    test "list_radios/0 returns all radios" do
      radio = radio_fixture()
      assert Radios.list_radios() == [radio]
    end

    test "get_radio!/1 returns the radio with given id" do
      radio = radio_fixture()
      assert Radios.get_radio!(radio.id) == radio
    end

    test "create_radio/1 with valid data creates a radio" do
      valid_attrs = %{name: "some name", description: "some description", url: "some url", genre: "some genre"}

      assert {:ok, %Radio{} = radio} = Radios.create_radio(valid_attrs)
      assert radio.name == "some name"
      assert radio.description == "some description"
      assert radio.url == "some url"
      assert radio.genre == "some genre"
    end

    test "create_radio/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Radios.create_radio(@invalid_attrs)
    end

    test "update_radio/2 with valid data updates the radio" do
      radio = radio_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", url: "some updated url", genre: "some updated genre"}

      assert {:ok, %Radio{} = radio} = Radios.update_radio(radio, update_attrs)
      assert radio.name == "some updated name"
      assert radio.description == "some updated description"
      assert radio.url == "some updated url"
      assert radio.genre == "some updated genre"
    end

    test "update_radio/2 with invalid data returns error changeset" do
      radio = radio_fixture()
      assert {:error, %Ecto.Changeset{}} = Radios.update_radio(radio, @invalid_attrs)
      assert radio == Radios.get_radio!(radio.id)
    end

    test "delete_radio/1 deletes the radio" do
      radio = radio_fixture()
      assert {:ok, %Radio{}} = Radios.delete_radio(radio)
      assert_raise Ecto.NoResultsError, fn -> Radios.get_radio!(radio.id) end
    end

    test "change_radio/1 returns a radio changeset" do
      radio = radio_fixture()
      assert %Ecto.Changeset{} = Radios.change_radio(radio)
    end
  end
end
