defmodule EchochamberWeb.Chamber.AdminLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts

  def render(assigns) do
    ~H"""
    <!-- admin player -->
    <div id="audio-player" phx-hook="AudioPlayer" class="w-full" role="region" aria-label="Player">
      <div class="w-full h-48" id="visual-container" phx-update="ignore"></div>
      <div id="audio-ignore" phx-update="ignore">
        <audio crossorigin="anonymous"></audio>
      </div>
      <div><%= @user %>'s chamber</div>
      <div><%= @title %></div>
      <div>Jungle by Arcando</div>
      <div><%= @count %> listeners</div>
      <%= if @playing? do %>
        <button phx-click="js_pause">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            class="w-8 h-8"
          >
            <path
              fill-rule="evenodd"
              d="M6.75 5.25a.75.75 0 0 1 .75-.75H9a.75.75 0 0 1 .75.75v13.5a.75.75 0 0 1-.75.75H7.5a.75.75 0 0 1-.75-.75V5.25Zm7.5 0A.75.75 0 0 1 15 4.5h1.5a.75.75 0 0 1 .75.75v13.5a.75.75 0 0 1-.75.75H15a.75.75 0 0 1-.75-.75V5.25Z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      <% else %>
        <button phx-click="js_play">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
            class="w-8 h-8"
          >
            <path
              fill-rule="evenodd"
              d="M4.5 5.653c0-1.427 1.529-2.33 2.779-1.643l11.54 6.347c1.295.712 1.295 2.573 0 3.286L7.28 19.99c-1.25.687-2.779-.217-2.779-1.643V5.653Z"
              clip-rule="evenodd"
            />
          </svg>
        </button>
      <% end %>
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
      <div class="flex flex-col w-fit gap-2 mt-2">
        Radios:
        <button
          class="p-5 bg-blue-100"
          phx-click="js_play_radio"
          phx-value-url="https://uk3.internet-radio.com/proxy/co9?mp=/stream"
          phx-value-title="UK 3"
        >
          UK 3
        </button>
        <button
          class="p-5 bg-blue-100"
          phx-click="js_play_radio"
          phx-value-url="https://technobeat.stream.laut.fm/technobeat"
          phx-value-title="Technobeat"
        >
          Technobeat
        </button>
      </div>
    </div>
    <!-- /admin player -->
    """
  end

  def mount(%{"user" => user}, _session, socket) do
    current_user = socket.assigns.current_user

    if user != current_user.username do
      {:ok, push_navigate(socket, to: ~p"/chamber/#{user}/lobby")}
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
       |> assign(title: "")
       |> assign(playing?: false)
       |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(user)))}
    end
  end

  def handle_event("js_play_radio", %{"url" => url, "title" => title}, socket) do
    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Song{
      radio_url: url,
      radio_title: title
    })

    {:noreply,
     socket
     |> assign(playing?: true)}
  end

  def handle_event("js_play", _params, socket) do
    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Pause{
      radio_url: nil
    })

    {:noreply,
     socket
     |> assign(playing?: true)}
  end

  def handle_event("js_pause", _params, socket) do
    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Pause{
      radio_url: nil
    })

    {:noreply,
     socket
     |> assign(playing?: false)}
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

  def handle_info({EchochamberWeb.Presence, {:join, _presence}}, socket) do
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
