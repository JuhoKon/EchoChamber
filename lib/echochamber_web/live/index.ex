defmodule EchochamberWeb.HomeLive do
  use EchochamberWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>Echochamber homepage. Discover users etc. <%= @foo %></div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :foo, "")}
  end
end
