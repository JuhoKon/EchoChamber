defmodule EchochamberWeb.RadioLive.Show do
  use EchochamberWeb, :live_view

  alias Echochamber.Radios

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:radio, Radios.get_radio!(id))}
  end

  defp page_title(:show), do: "Show Radio"
  defp page_title(:edit), do: "Edit Radio"
end
