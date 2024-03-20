defmodule EchochamberWeb.RadioLive.Index do
  use EchochamberWeb, :live_view

  alias Echochamber.Radios
  alias Echochamber.Radios.Radio

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :radios, Radios.list_radios())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Radio")
    |> assign(:radio, Radios.get_radio!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Radio")
    |> assign(:radio, %Radio{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Radios")
    |> assign(:radio, nil)
  end

  @impl true
  def handle_info({EchochamberWeb.RadioLive.FormComponent, {:saved, radio}}, socket) do
    {:noreply, stream_insert(socket, :radios, radio)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    radio = Radios.get_radio!(id)
    {:ok, _} = Radios.delete_radio(radio)

    {:noreply, stream_delete(socket, :radios, radio)}
  end
end
