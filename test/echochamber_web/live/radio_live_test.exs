defmodule EchochamberWeb.RadioLiveTest do
  use EchochamberWeb.ConnCase

  import Phoenix.LiveViewTest
  import Echochamber.RadiosFixtures

  @create_attrs %{name: "some name", description: "some description", url: "some url", genre: "some genre"}
  @update_attrs %{name: "some updated name", description: "some updated description", url: "some updated url", genre: "some updated genre"}
  @invalid_attrs %{name: nil, description: nil, url: nil, genre: nil}

  defp create_radio(_) do
    radio = radio_fixture()
    %{radio: radio}
  end

  describe "Index" do
    setup [:create_radio]

    test "lists all radios", %{conn: conn, radio: radio} do
      {:ok, _index_live, html} = live(conn, ~p"/radios")

      assert html =~ "Listing Radios"
      assert html =~ radio.name
    end

    test "saves new radio", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/radios")

      assert index_live |> element("a", "New Radio") |> render_click() =~
               "New Radio"

      assert_patch(index_live, ~p"/radios/new")

      assert index_live
             |> form("#radio-form", radio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#radio-form", radio: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/radios")

      html = render(index_live)
      assert html =~ "Radio created successfully"
      assert html =~ "some name"
    end

    test "updates radio in listing", %{conn: conn, radio: radio} do
      {:ok, index_live, _html} = live(conn, ~p"/radios")

      assert index_live |> element("#radios-#{radio.id} a", "Edit") |> render_click() =~
               "Edit Radio"

      assert_patch(index_live, ~p"/radios/#{radio}/edit")

      assert index_live
             |> form("#radio-form", radio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#radio-form", radio: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/radios")

      html = render(index_live)
      assert html =~ "Radio updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes radio in listing", %{conn: conn, radio: radio} do
      {:ok, index_live, _html} = live(conn, ~p"/radios")

      assert index_live |> element("#radios-#{radio.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#radios-#{radio.id}")
    end
  end

  describe "Show" do
    setup [:create_radio]

    test "displays radio", %{conn: conn, radio: radio} do
      {:ok, _show_live, html} = live(conn, ~p"/radios/#{radio}")

      assert html =~ "Show Radio"
      assert html =~ radio.name
    end

    test "updates radio within modal", %{conn: conn, radio: radio} do
      {:ok, show_live, _html} = live(conn, ~p"/radios/#{radio}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Radio"

      assert_patch(show_live, ~p"/radios/#{radio}/show/edit")

      assert show_live
             |> form("#radio-form", radio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#radio-form", radio: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/radios/#{radio}")

      html = render(show_live)
      assert html =~ "Radio updated successfully"
      assert html =~ "some updated name"
    end
  end
end
