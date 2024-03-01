defmodule EchochamberWeb.OnlineLive do
  use EchochamberWeb, :live_view

  def mount(_params, _session, socket) do
    socket = stream(socket, :presences, [])

    socket =
      if connected?(socket) do
        EchochamberWeb.Presence.track_user(socket.assigns.current_user.email, %{id: socket.assigns.current_user.email})
        EchochamberWeb.Presence.subscribe()
        stream(socket, :presences, EchochamberWeb.Presence.list_online_users())
      else
        socket
      end

    {:ok, socket
          |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
  end

  def render(assigns) do
    ~H"""
    <ul id="online_users" phx-update="stream">
      <li :for={{dom_id, %{id: id, metas: metas}} <- @streams.presences} id={dom_id}>
        <%= id %> (<%= length(metas) %>)
      </li>
    </ul>
    """
  end

  def handle_info({EchochamberWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)
    |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)
      |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
    else
      {:noreply, stream_insert(socket, :presences, presence)
      |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
    end
  end
end
