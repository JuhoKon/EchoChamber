defmodule EchochamberWeb.RadioLive do
  use EchochamberWeb, :live_view
  alias Echochamber.Accounts

  def render(assigns) do
    ~H"""
    <div>Welcome to <%= @user %>'s radio!</div>
    <%= if @user == @current_user.username do %>
      <button class="p-10 bg-blue-100" phx-click="asiaa">asiaa</button>
      <button class="p-10 bg-blue-100" phx-click="ei_asiaa">ei asiaa</button>
    <% end %>
    <%= if @msg do %>
      <div><%= @msg %></div>
    <% end %>

    <div>Active listeners: <%= @count %></div>
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

  def handle_event("asiaa", _params, socket) do
    Accounts.broadcast_message(socket.assigns.current_user, "Asiaa")
    {:noreply, socket}
  end

  def handle_event("ei_asiaa", _params, socket) do
    Accounts.broadcast_message(socket.assigns.current_user, "Ei asiaa")
    {:noreply, socket}
  end

  def handle_info(
        {Accounts, %Accounts.Events.Message{msg: msg}},
        socket
      ) do
    if msg do
      {:noreply, assign(socket, msg: msg)}
    else
      {:noreply, socket}
    end
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
