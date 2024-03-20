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
      <h3 class="pt-6 p-4 pl-0 ml-4 text-xs">
        PRIMARY
      </h3>
      <div class="mt-1 space-y-1" role="group">
        <.link
          navigate={~p"/radios"}
          class="group flex items-center pl-5 px-3 py-2 text-sm leading-5 rounded-md gap-4"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            class="w-6 h-6"
          >
            <path
              fill-rule="evenodd"
              d="M20.432 4.103a.75.75 0 0 0-.364-1.456L4.128 6.632l-.2.033C2.498 6.904 1.5 8.158 1.5 9.574v9.176a3 3 0 0 0 3 3h15a3 3 0 0 0 3-3V9.574c0-1.416-.997-2.67-2.429-2.909a49.017 49.017 0 0 0-7.255-.658l7.616-1.904Zm-9.585 8.56a.75.75 0 0 1 0 1.06l-.005.006a.75.75 0 0 1-1.06 0l-.006-.006a.75.75 0 0 1 0-1.06l.005-.005a.75.75 0 0 1 1.06 0l.006.005ZM9.781 15.85a.75.75 0 0 0 1.061 0l.005-.005a.75.75 0 0 0 0-1.061l-.005-.005a.75.75 0 0 0-1.06 0l-.006.005a.75.75 0 0 0 0 1.06l.005.006Zm-1.055-1.066a.75.75 0 0 1 0 1.06l-.005.006a.75.75 0 0 1-1.061 0l-.005-.005a.75.75 0 0 1 0-1.06l.005-.006a.75.75 0 0 1 1.06 0l.006.005ZM7.66 13.73a.75.75 0 0 0 1.061 0l.005-.006a.75.75 0 0 0 0-1.06l-.005-.006a.75.75 0 0 0-1.06 0l-.006.006a.75.75 0 0 0 0 1.06l.005.006ZM9.255 9.75a.75.75 0 0 1 .75.75v.008a.75.75 0 0 1-.75.75h-.008a.75.75 0 0 1-.75-.75V10.5a.75.75 0 0 1 .75-.75h.008Zm3.624 3.28a.75.75 0 0 0 .275-1.025L13.15 12a.75.75 0 0 0-1.025-.275l-.006.004a.75.75 0 0 0-.275 1.024l.004.007a.75.75 0 0 0 1.025.274l.006-.003Zm-1.38 5.126a.75.75 0 0 1-1.024-.275l-.004-.006a.75.75 0 0 1 .275-1.025l.006-.004a.75.75 0 0 1 1.025.275l.004.007a.75.75 0 0 1-.275 1.024l-.006.004Zm.282-6.776a.75.75 0 0 0-.274-1.025l-.007-.003a.75.75 0 0 0-1.024.274l-.004.007a.75.75 0 0 0 .274 1.024l.007.004a.75.75 0 0 0 1.024-.275l.004-.006Zm1.369 5.129a.75.75 0 0 1-1.025.274l-.006-.004a.75.75 0 0 1-.275-1.024l.004-.007a.75.75 0 0 1 1.025-.274l.006.004a.75.75 0 0 1 .275 1.024l-.004.007Zm-.145-1.502a.75.75 0 0 0 .75-.75v-.007a.75.75 0 0 0-.75-.75h-.008a.75.75 0 0 0-.75.75v.007c0 .415.336.75.75.75h.008Zm-3.75 2.243a.75.75 0 0 1 .75.75v.008a.75.75 0 0 1-.75.75h-.008a.75.75 0 0 1-.75-.75V18a.75.75 0 0 1 .75-.75h.008Zm-2.871-.47a.75.75 0 0 0 .274-1.025l-.003-.006a.75.75 0 0 0-1.025-.275l-.006.004a.75.75 0 0 0-.275 1.024l.004.007a.75.75 0 0 0 1.024.274l.007-.003Zm1.366-5.12a.75.75 0 0 1-1.025-.274l-.004-.006a.75.75 0 0 1 .275-1.025l.006-.004a.75.75 0 0 1 1.025.275l.004.006a.75.75 0 0 1-.275 1.025l-.006.004Zm.281 6.215a.75.75 0 0 0-.275-1.024l-.006-.004a.75.75 0 0 0-1.025.274l-.003.007a.75.75 0 0 0 .274 1.024l.007.004a.75.75 0 0 0 1.024-.274l.004-.007Zm-1.376-5.116a.75.75 0 0 1-1.025.274l-.006-.003a.75.75 0 0 1-.275-1.025l.004-.007a.75.75 0 0 1 1.025-.274l.006.004a.75.75 0 0 1 .275 1.024l-.004.007Zm-1.15 2.248a.75.75 0 0 0 .75-.75v-.007a.75.75 0 0 0-.75-.75h-.008a.75.75 0 0 0-.75.75v.007c0 .415.336.75.75.75h.008ZM17.25 10.5a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Zm1.5 6a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0Z"
              clip-rule="evenodd"
            />
          </svg>

          <div class="flex flex-col">
            <span class="line-clamp-1">
              Manage radios
            </span>
          </div>
        </.link>
      </div>
      <h3 class="pt-6 p-4 pl-0 ml-4 text-xs">
        ACTIVE USERS
      </h3>
      <div class="mt-1 space-y-1" role="group">
        <%= for user <- @active_users do %>
          <.link
            navigate={home_path(user.user)}
            class="group flex items-center pl-5 px-3 py-2 text-sm leading-5 rounded-md gap-4"
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
