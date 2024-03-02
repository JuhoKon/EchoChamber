defmodule EchochamberWeb.OnlineLive do
  use EchochamberWeb, :live_view

  on_mount {EchochamberWeb.UserAuth, :mount_current_user}
  
  def mount(_params, _session, socket) do
    IO.puts("WHAT")
    IO.inspect(socket)
    socket = stream(socket, :presences, [])

    socket =
      if connected?(socket) do
        EchochamberWeb.Presence.track_user(socket.assigns.current_user.email, %{
          id: socket.assigns.current_user.email
        })

        EchochamberWeb.Presence.subscribe()
        stream(socket, :presences, EchochamberWeb.Presence.list_online_users())
      else
        socket
      end

    {:ok,
     socket
     |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3 class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider">
        Active Users
      </h3>
      <div class="mt-1 space-y-1" role="group">
        <%= for user <- @active_users do %>
        <.link
          navigate={home_path(@current_user)}
          class="group flex items-center px-3 py-2 text-base leading-5 font-medium text-gray-600 rounded-md hover:text-gray-900 hover:bg-gray-50">
          <span class="w-2.5 h-2.5 mr-4 bg-indigo-500 rounded-full" aria-hidden="true"></span>
          <span class="truncate">
            <%= user.id %>
          </span>
        </.link>
        <% end %>
      </div>
    </div>
        """
  end

  def handle_info({EchochamberWeb.Presence, {:join, presence}}, socket) do
    {:noreply,
     stream_insert(socket, :presences, presence)
     |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply,
       stream_delete(socket, :presences, presence)
       |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
    else
      {:noreply,
       stream_insert(socket, :presences, presence)
       |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
    end
  end
end
