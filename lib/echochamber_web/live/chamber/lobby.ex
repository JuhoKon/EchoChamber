defmodule EchochamberWeb.Chamber.LobbyLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts

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
       |> assign(
         radio_status: %{
           radio_url: nil,
           radio_title: nil,
           track_title: nil,
           playing?: nil
         }
       )
       |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(user)))}
    end
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

  def handle_info({EchochamberWeb.Presence, {:join, presence}}, socket) do
    {:noreply,
     socket
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user)))}
  end

  def handle_info({EchochamberWeb.Presence, {:leave, presence}}, socket) do
    {:noreply,
     socket
     |> assign(count: Enum.count(EchochamberWeb.Presence.list_profile_users(socket.assigns.user)))}
  end
end
