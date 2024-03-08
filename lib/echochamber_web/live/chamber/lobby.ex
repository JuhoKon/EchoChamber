defmodule EchochamberWeb.Chamber.LobbyLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts

  def render(assigns) do
    ~H"""
    <!-- lobby player -->
    <div id="audio-player" phx-hook="AudioPlayer" class="w-full" role="region" aria-label="Player">
      <div id="audio-ignore" phx-update="ignore">
        <audio crossorigin="anonymous"></audio>
      </div>
      <h1 class="text-lg text-zinc-900 font-bold pt-4 text-center"><%= @user %>'s chamber</h1>
      <div class="text-zinc-500 text-sm text-center"><%= @count %> listeners</div>
      <div class="w-full h-96" id="visual-container" phx-update="ignore"></div>
      <div class="flex items-center justify-end gap-10">
        <div class="flex items-center pr-4 gap-2">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            class="w-6 h-6"
          >
            <path d="M13.5 4.06c0-1.336-1.616-2.005-2.56-1.06l-4.5 4.5H4.508c-1.141 0-2.318.664-2.66 1.905A9.76 9.76 0 0 0 1.5 12c0 .898.121 1.768.35 2.595.341 1.24 1.518 1.905 2.659 1.905h1.93l4.5 4.5c.945.945 2.561.276 2.561-1.06V4.06ZM18.584 5.106a.75.75 0 0 1 1.06 0c3.808 3.807 3.808 9.98 0 13.788a.75.75 0 0 1-1.06-1.06 8.25 8.25 0 0 0 0-11.668.75.75 0 0 1 0-1.06Z" />
            <path d="M15.932 7.757a.75.75 0 0 1 1.061 0 6 6 0 0 1 0 8.486.75.75 0 0 1-1.06-1.061 4.5 4.5 0 0 0 0-6.364.75.75 0 0 1 0-1.06Z" />
          </svg>
          <input type="range" id="lobby_volume" name="volume" min="0" max="100" start="50" />
        </div>
      </div>
      <h2 class="text-center text-zinc-900 text-4xl"><%= @title %></h2>
      <div class="text-zinc-500 text-sm text-center pt-2">Now playing</div>
      <div class="text-center font-bold">Jungle by Arcando</div>
    </div>
    <!-- /lobby player -->
    """
  end

  def mount(%{"user" => user}, _session, socket) do
    current_user = socket.assigns.current_user

    if user == current_user.username do
      {:ok, push_navigate(socket, to: ~p"/chamber/#{current_user.username}/admin")}
    else
      socket =
        if connected?(socket) do
          EchochamberWeb.Presence.track_user(user, socket.assigns.current_user.email, %{
            id: socket.assigns.current_user.id
          })

          EchochamberWeb.Presence.subscribe(user)
          Accounts.subscribe(socket.assigns.current_user.id)
          socket
        else
          socket
        end

      Accounts.subscribe(user)

      {:ok,
       socket
       |> assign(user: user)
       |> assign(title: "Technobeat")
       |> assign(playing?: false)
       |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(user)))}
    end
  end

  def handle_event("update_volume", %{"volume" => volume}, socket) do
    # You can perform any necessary processing here, such as updating the volume value in the assigns
    {:noreply, assign(socket, volume: volume)}
  end

  def handle_info({Accounts, %Accounts.Events.Play_Pause{radio_url: url}}, socket) do
    {:noreply,
     push_event(socket, "play_pause", %{
       url: url
     })}
  end

  def handle_info({Accounts, %Accounts.Events.Pause{radio_url: url}}, socket) do
    {:noreply,
     push_event(socket, "pause", %{
       url: url
     })}
  end

  def handle_info(
        {Accounts, %Accounts.Events.Play_Song{radio_url: url, radio_title: title}},
        socket
      ) do
    {:noreply,
     push_event(socket, "play", %{
       url: url
     })
     |> assign(title: title)}
  end

  def handle_info({EchochamberWeb.Presence, {:join, presence}}, socket) do
    {:noreply,
     socket
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user)))}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply,
       socket
       |> assign(
         count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user))
       )}
    else
      {:noreply,
       socket
       |> assign(
         count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user))
       )}
    end
  end
end
