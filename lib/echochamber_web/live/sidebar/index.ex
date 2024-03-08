defmodule EchochamberWeb.SidebarLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts
  on_mount {EchochamberWeb.UserAuth, :mount_current_user}

  defp add_listeners_to_user(user) do
    Map.put(
      user,
      :listeners,
      Enum.count(EchochamberWeb.Presence.list_profile_users(user.user.username))
    )
  end

  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        EchochamberWeb.Presence.track_user("online_users", socket.assigns.current_user.email, %{
          id: socket.assigns.current_user.id
        })

        EchochamberWeb.Presence.subscribe("online_users")
        Accounts.subscribe(socket.assigns.current_user.id)
        socket
      else
        socket
      end

    {:ok,
     socket
     |> assign(
       active_users:
         Enum.map(EchochamberWeb.Presence.list_online_users(), &add_listeners_to_user(&1))
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full">
      <h3 class="text-zinc-900 font-bold p-4 ml-4">
        Active Users
      </h3>
      <div class="mt-1 space-y-1" role="group">
        <%= for user <- @active_users do %>
          <.link
            navigate={home_path(user.user)}
            class="group flex items-center px-3 py-2 text-base leading-5 font-medium text-zinc-900 rounded-md hover:text-gray-900 gap-4"
          >
            <img
              class="h-10"
              src="https://upload.wikimedia.org/wikipedia/commons/5/59/User-avatar.svg"
            />
            <div class="flex flex-col">
              <span class="truncate">
                <%= user.user.username %>
              </span>
              <span class="text-zinc-500 text-sm"><%= user.listeners %> listener(s)</span>
            </div>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_info({EchochamberWeb.Presence, {:join, _presence}}, socket) do
    {:noreply,
     socket
     |> assign(
       active_users:
         Enum.map(EchochamberWeb.Presence.list_online_users(), &add_listeners_to_user(&1))
     )}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply,
       socket
       |> assign(
         active_users:
           Enum.map(EchochamberWeb.Presence.list_online_users(), &add_listeners_to_user(&1))
       )}
    else
      {:noreply,
       socket
       |> assign(
         active_users:
           Enum.map(EchochamberWeb.Presence.list_online_users(), &add_listeners_to_user(&1))
       )}
    end
  end
end
