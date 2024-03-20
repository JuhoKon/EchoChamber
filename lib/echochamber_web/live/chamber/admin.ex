defmodule EchochamberWeb.Chamber.AdminLive do
  use EchochamberWeb, :live_view
  use Timex

  alias Echochamber.Accounts
  alias Echochamber.Shoutcast

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
       |> assign(user: user)
       |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(user)))
       |> stream(:history, [])
       |> stream(:radios, [
         %{
           id: 1,
           url: "https://uk3.internet-radio.com/proxy/co9?mp=/stream",
           title: "CO9",
           description: "UK3 CO0 bängereitä",
           genre: "EDM"
         },
         %{
           id: 2,
           url: "https://technobeat.stream.laut.fm/technobeat",
           title: "Technobeat",
           description: "Teknoloota",
           genre: "Techno"
         },
         %{
           id: 3,
           url: "https://uk2.internet-radio.com/proxy/danceradiouk?mp=/stream",
           title: "Dance UK Radio",
           description: "UK dance music",
           genre: "EDM"
         },
         %{
           id: 4,
           url: "https://streaming.exclusive.radio/er/eminem/icecast.audio",
           title: "Eminem Exclusive",
           description: "Pelkkää eminemiä",
           genre: "Rap"
         }
       ])}
    end
  end

  def handle_event("js_play_radio", %{"url" => url, "title" => title}, socket) do
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

    Process.send_after(self(), :get_track_info, 9000)

    {:noreply, new_socket}
  end

  defp update_history(track_title, radio_title, socket) do
    %{radio_status: radio_status} = socket.assigns

    %{track_title: prev_track_title} = radio_status

    is_new_track =
      case track_title do
        ^prev_track_title -> false
        "Unknown track" -> false
        _ -> true
      end

    if is_new_track do
      new_history_item = %{
        id: Timex.now(),
        radio_title: radio_title,
        track_title: track_title,
        track_played_at: Timex.now()
      }

      socket
      |> stream_insert(:history, new_history_item, at: 0, limit: 25)
    else
      socket
    end
  end
end
