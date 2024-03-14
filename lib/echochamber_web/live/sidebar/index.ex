defmodule EchochamberWeb.SidebarLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts
  on_mount {EchochamberWeb.UserAuth, :mount_current_user}

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
     |> assign(active_users: EchochamberWeb.Presence.list_online_users()), layout: false}
  end

  # TODO Show users that have an active broadcast. Should be stored in db. Could move away from presence to some sort of interval implementation.
  def render(assigns) do
    ~H"""
    <div class="w-full text-black font-light">
      <h3 class="pt-6 p-4 pl-0 ml-4 text-sm">
        ACTIVE USERS
      </h3>
      <div class="mt-1 space-y-1" role="group">
        <%= for user <- @active_users do %>
          <.link
            navigate={home_path(user.user)}
            class="text-base group flex items-center pl-5 px-3 py-2 text-base leading-5 rounded-md gap-4"
          >
            <img
              class="h-6"
              src="https://upload.wikimedia.org/wikipedia/commons/5/59/User-avatar.svg"
            />
            <%= if @current_user.username == user.user.username do %>
              <div class="flex flex-col">
                <span class="line-clamp-1">
                  <%= user.user.username %> (you)
                </span>
              </div>
            <% else %>
              <div class="flex flex-col">
                <span class="line-clamp-1">
                  <%= user.user.username %>
                </span>
              </div>
            <% end %>
          </.link>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_info({EchochamberWeb.Presence, {:join, _presence}}, socket) do
    {:noreply,
     socket
     |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, _presence}}, socket) do
    {:noreply,
     socket
     |> assign(active_users: EchochamberWeb.Presence.list_online_users())}
  end
end
