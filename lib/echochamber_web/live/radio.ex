defmodule EchochamberWeb.RadioLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts

  def render(assigns) do
    ~H"""
    <!-- player -->
    <div id="audio-player" phx-hook="AudioPlayer" class="w-full" role="region" aria-label="Player">
      <div class="w-full h-48" id="visual-container"></div>
      <div id="audio-ignore" phx-update="ignore">
        <audio crossorigin="anonymous"></audio>
      </div>
      <%= if @user == @current_user.username do %>
        <button class="p-5 bg-blue-100" phx-click="js_play">Play</button>
        <button class="p-5 bg-blue-100" phx-click="js_pause">Pause</button>
        <div class="flex flex-col w-fit gap-2 mt-2">
          Radios:
          <button
            class="p-5 bg-blue-100"
            phx-click="js_play_radio"
            phx-value-url="https://uk3.internet-radio.com/proxy/co9?mp=/stream"
          >
            UK 3
          </button>
          <button
            class="p-5 bg-blue-100"
            phx-click="js_play_radio"
            phx-value-url="https://technobeat.stream.laut.fm/technobeat"
          >
            Technobeat
          </button>
        </div>
      <% end %>
    </div>
    <!-- /player -->
    """
  end

  def mount(%{"user" => user}, _session, socket) do
    socket = stream(socket, :presences, [])

    socket =
      if connected?(socket) do
        EchochamberWeb.Presence.track_user(user, socket.assigns.current_user.email, %{
          id: socket.assigns.current_user.id
        })

        EchochamberWeb.Presence.subscribe(user)
        Accounts.subscribe(socket.assigns.current_user.id)
        stream(socket, :presences, EchochamberWeb.Presence.list_profile_users(user))
      else
        socket
      end

    Accounts.subscribe(user)

    {:ok,
     socket
     |> assign(user: user)
     |> assign(msg: nil)
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(user)))}
  end

  def handle_event("js_play_radio", %{"url" => url}, socket) do
    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Song{
      radio: url
    })

    {:noreply, socket}
  end

  def handle_event("js_play", _params, socket) do
    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Pause{
      radio: nil
    })

    {:noreply, socket}
  end

  def handle_event("js_pause", _params, socket) do
    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Pause{radio: nil})

    {:noreply, socket}
  end

  def handle_info({Accounts, %Accounts.Events.Play_Pause{radio: url}}, socket) do
    {:noreply,
     push_event(socket, "play_pause", %{
       url: url
     })}
  end

  def handle_info({Accounts, %Accounts.Events.Pause{radio: url}}, socket) do
    {:noreply,
     push_event(socket, "pause", %{
       url: url
     })}
  end

  def handle_info({Accounts, %Accounts.Events.Play_Song{radio: url}}, socket) do
    {:noreply,
     push_event(socket, "play", %{
       url: url
     })}
  end

  def handle_info({EchochamberWeb.Presence, {:join, presence}}, socket) do
    {:noreply,
     stream_insert(socket, :presences, presence)
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user)))}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply,
       stream_delete(socket, :presences, presence)
       |> assign(
         count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user))
       )}
    else
      {:noreply,
       stream_insert(socket, :presences, presence)
       |> assign(
         count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user))
       )}
    end
  end
end
