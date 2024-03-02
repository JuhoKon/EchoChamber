defmodule EchochamberWeb.RadioLive do
  use EchochamberWeb, :live_view

  def mount(%{"user" => user}, _session, socket) do
    {:ok,
     socket
     |> assign(user: user)}
  end

  def render(assigns) do
    ~H"""
    <div>Welcome to <%= @user %>'s radio!</div>
    """
  end
end
