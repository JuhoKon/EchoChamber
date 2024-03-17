defmodule EchochamberWeb.Chamber.AdminLive do
  use EchochamberWeb, :live_view
  use Timex

  alias Echochamber.Accounts
  alias Echochamber.Shoutcast

  def render(assigns) do
    ~H"""
    <!-- admin player -->
    <div
      id="audio-player"
      phx-hook="AudioPlayer"
      class="w-full h-full px-4 py-4 flex flex-col"
      role="region"
      aria-label="Player"
    >
      <div id="admin-visualizer" phx-hook="AudioMotionAnalyzerAdmin" class="w-full h-[20%]">
        <div class="h-full" id="visual-container" phx-update="ignore">
          <div id="audio-ignore" phx-update="ignore">
            <audio crossorigin="anonymous"></audio>
          </div>
        </div>
      </div>
      <h1 class="text-lg text-black text-center font-bold">Hello, <%= @current_user.username %></h1>

      <div class="text-black text-xs text-center py-2">
        You have: <%= @count %> listeners (including you)
      </div>

      <div class="flex justify-between content-center mt-2">
        <div class="flex items-center gap-2 flex-1" phx-update="ignore" id="admin-player">
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
        <%= if @radio_status.playing? do %>
          <button phx-click="js_pause">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
              class="w-12 h-12"
            >
              <path
                fill-rule="evenodd"
                d="M6.75 5.25a.75.75 0 0 1 .75-.75H9a.75.75 0 0 1 .75.75v13.5a.75.75 0 0 1-.75.75H7.5a.75.75 0 0 1-.75-.75V5.25Zm7.5 0A.75.75 0 0 1 15 4.5h1.5a.75.75 0 0 1 .75.75v13.5a.75.75 0 0 1-.75.75H15a.75.75 0 0 1-.75-.75V5.25Z"
                clip-rule="evenodd"
              />
            </svg>
          </button>
        <% else %>
          <button
            phx-click="js_play"
            disabled={if @radio_status.radio_url == nil, do: true, else: false}
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
              class="w-12 h-12"
            >
              <path
                fill-rule="evenodd"
                d="M4.5 5.653c0-1.427 1.529-2.33 2.779-1.643l11.54 6.347c1.295.712 1.295 2.573 0 3.286L7.28 19.99c-1.25.687-2.779-.217-2.779-1.643V5.653Z"
                clip-rule="evenodd"
              />
            </svg>
          </button>
        <% end %>
        <div class="flex-1"></div>
      </div>
      <div class="flex justify-between mt-4 flex-wrap grow min-h-0">
        <div class="flex flex-col basis-[48%] gap-4 h-full">
          <div class="flex flex-col gap-4 border border-zinc-300 py-4 px-2">
            <div class="text-base text-black text-center">
              <span class="font-bold">Radio:</span> <%= @radio_status.radio_title %>
            </div>
            <div class="text-base text-black text-center">
              <span class="font-bold">Current track:</span>
              <%= if @radio_status.track_title == nil do %>
                Unknown track
              <% else %>
                <%= @radio_status.track_title %>
              <% end %>
            </div>

            <h1 class="text-base text-black font-bold text-center">
              <%= cond do %>
                <% @radio_status.radio_title == nil -> %>
                  Status: Offline
                <% @radio_status.playing? == :false -> %>
                  Status: Paused
                <% true -> %>
                  Status: Online
              <% end %>
            </h1>
          </div>
          <div class="border border-zinc-300 h-full flex flex-col min-h-0">
            <div class="text-base text-black text-center mt-4">
              <span class="font-bold">History:</span> Last 25 tracks
            </div>
            <div class="h-full overflow-auto mt-4">
              <table class="min-w-full divide-y">
                <thead>
                  <tr>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-semibold text-gray-800 uppercase tracking-wider"
                    >
                      #
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-semibold text-gray-800 uppercase tracking-wider"
                    >
                      Track Title
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-semibold text-gray-800 uppercase tracking-wider"
                    >
                      Radio Name
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-3 text-left text-xs font-semibold text-gray-800 uppercase tracking-wider"
                    >
                      Played At
                    </th>
                  </tr>
                </thead>
                <tbody class="divide-y">
                  <%= for {history_item, index} <- Enum.with_index(@history, 1) do %>
                    <tr>
                      <td class="px-6 py-4 whitespace-nowrap text-xs font-medium">
                        <%= index %>.
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-xs text-pretty max-w-40">
                        <%= history_item.track_title %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-xs">
                        <%= history_item.radio_title %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-xs">
                        <%= case history_item.track_played_at
                                 |> Timex.local()
                                 |> Timex.format("%H:%M:%S", :strftime) do
                          {:ok, formatted_string} -> formatted_string
                          _ -> "Unknown time"
                        end %>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div>
        <div class="border border-zinc-300 basis-[48%] h-full overflow-auto">
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
            <button
              class="p-5 bg-blue-100"
              phx-click="js_play_radio"
              phx-value-url="https://uk2.internet-radio.com/proxy/danceradiouk?mp=/stream"
              phx-value-title="Dance UK Radio danceradiouk"
            >
              Dance UK Radio danceradiouk
            </button>
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
            <button
              class="p-5 bg-blue-100"
              phx-click="js_play_radio"
              phx-value-url="https://uk2.internet-radio.com/proxy/danceradiouk?mp=/stream"
              phx-value-title="Dance UK Radio danceradiouk"
            >
              Dance UK Radio danceradiouk
            </button>
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
            <button
              class="p-5 bg-blue-100"
              phx-click="js_play_radio"
              phx-value-url="https://uk2.internet-radio.com/proxy/danceradiouk?mp=/stream"
              phx-value-title="Dance UK Radio danceradiouk"
            >
              Dance UK Radio danceradiouk
            </button>
          </div>
        </div>
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

      Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Stop_Song{})

      {:ok,
       socket
       |> assign(
         radio_status: %{radio_url: nil, radio_title: nil, track_title: nil, playing?: nil}
       )
       |> assign(history: [])
       |> assign(user: user)
       |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(user)))}
    end
  end

  def handle_event("js_play_radio", %{"url" => url, "title" => title}, socket) do
    %{radio_status: radio_status} = socket.assigns
    %{track_title: track_title} = radio_status

    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Song{
      radio_url: url,
      radio_title: title,
      track_title: "Unknown track"
    })

    Process.send_after(self(), :get_track_info, 100)

    {:noreply, socket}
  end

  def handle_event("js_play", _params, socket) do
    %{radio_status: radio_status} = socket.assigns
    %{radio_url: radio_url, radio_title: radio_title, track_title: track_title} = radio_status

    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Pause{
      radio_url: radio_url,
      radio_title: radio_title,
      track_title: track_title
    })

    {:noreply, socket}
  end

  def handle_event("js_pause", _params, socket) do
    %{radio_status: radio_status} = socket.assigns
    %{radio_url: radio_url, radio_title: radio_title, track_title: track_title} = radio_status

    Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Pause{
      radio_url: radio_url,
      radio_title: radio_title,
      track_title: track_title
    })

    {:noreply, socket}
  end

  def handle_info(
        {Accounts, event = %Accounts.Events.Play_Pause{}},
        socket
      ) do
    %{radio_url: url} = event

    {:noreply,
     push_event(socket, "play", %{
       url: url
     })
     |> assign(radio_status: event)}
  end

  def handle_info({Accounts, event = %Accounts.Events.Pause{}}, socket) do
    %{radio_url: url} = event

    {:noreply,
     push_event(socket, "pause", %{
       url: url
     })
     |> assign(radio_status: event)}
  end

  def handle_info(
        {Accounts, event = %Accounts.Events.Play_Song{}},
        socket
      ) do
    %{radio_url: url} = event

    {:noreply,
     push_event(socket, "play", %{
       url: url
     })
     |> assign(radio_status: event)}
  end

  def handle_info(
        {Accounts, event = %Accounts.Events.Stop_Song{}},
        socket
      ) do
    {:noreply,
     push_event(socket, "stop", %{})
     |> assign(radio_status: event)}
  end

  def handle_info(
        {Accounts, event = %Accounts.Events.Update_Track_Title{}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(radio_status: event)}
  end

  def handle_info({EchochamberWeb.Presence, {:join, _presence}}, socket) do
    %{radio_status: radio_status} = socket.assigns

    %{
      radio_url: radio_url,
      radio_title: radio_title,
      track_title: track_title,
      playing?: playing?
    } = radio_status

    if radio_url != "" and playing? do
      Accounts.broadcast_radio_event(socket.assigns.current_user, %Accounts.Events.Play_Song{
        radio_url: radio_url,
        radio_title: radio_title,
        track_title: track_title
      })
    end

    {:noreply,
     socket
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user)))}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, _presence}}, socket) do
    {:noreply,
     socket
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user)))}
  end

  def handle_info(:get_track_info, socket) do
    %{radio_status: radio_status} = socket.assigns

    %{radio_url: radio_url} = radio_status

    {:noreply,
     socket
     |> start_async(:get_track_info, fn ->
       {:ok, meta} = Shoutcast.read_meta(radio_url)

       track_title =
         case meta.data["StreamTitle"] do
           "" -> nil
           value -> value
         end

       track_title
     end)}
  end

  def handle_async(:get_track_info, {:ok, {:error, _reason}}, socket) do
    # TODO handle
    {:noreply, socket}
  end

  def handle_async(:get_track_info, {:exit, _reason}, socket) do
    # TODO handle
    {:noreply, socket}
  end

  def handle_async(:get_track_info, {:ok, track_title}, socket) do
    %{radio_status: radio_status} = socket.assigns

    %{
      radio_url: radio_url,
      radio_title: radio_title,
      playing?: playing?
    } = radio_status

    new_socket =
      if track_title not in [nil, ""] do
        Accounts.broadcast_radio_event(
          socket.assigns.current_user,
          %Accounts.Events.Update_Track_Title{
            radio_url: radio_url,
            radio_title: radio_title,
            track_title: track_title,
            playing?: playing?
          }
        )

        update_history(track_title, radio_title, socket)
      else
        socket
      end

    Process.send_after(self(), :get_track_info, 5000)

    {:noreply, new_socket}
  end

  defp update_history(track_title, radio_title, socket) do
    history = socket.assigns.history || []

    # Check if the track is already the most recent in the history
    is_new_track =
      case history do
        [%{track_title: first_track_title} | _] -> first_track_title != track_title
        _ -> true
      end

    if is_new_track do
      new_history_item = %{
        radio_title: radio_title,
        track_title: track_title,
        track_played_at: Timex.now()
      }

      # Prepend the new item and trim the history to the latest 25 entries
      new_history = [new_history_item | history] |> Enum.take(25)

      # Update the socket assigns with the new history
      assign(socket, :history, new_history)
    else
      socket
    end
  end
end
