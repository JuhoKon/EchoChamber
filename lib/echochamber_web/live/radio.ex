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
    """
  end

  def mount(%{"user" => user}, _session, socket) do
    Accounts.subscribe(user)

    {:ok,
     socket
     |> assign(user: user)
     |> assign(msg: nil)}
  end

  def handle_info(
        {Accounts, %Accounts.Events.Haloo{msg: msg}},
        socket
      ) do
    if msg do
      {:noreply, assign(socket, msg: msg)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("asiaa", _params, socket) do
    Accounts.testihaloo(socket.assigns.current_user, "Asiaa")
    {:noreply, socket}
  end

  def handle_event("ei_asiaa", _params, socket) do
    Accounts.testihaloo(socket.assigns.current_user, "Ei asiaa")
    {:noreply, socket}
  end
end
