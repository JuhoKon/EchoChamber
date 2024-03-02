defmodule EchochamberWeb.HomeLive do
  use EchochamberWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>Hello <%= @temperature %></div>
    <button phx-click="inc_temperature">+</button>
    """
  end

  def mount(_params, _session, socket) do
    # Let's assume a fixed temperature for now
    temperature = 70
    {:ok, assign(socket, :temperature, temperature)}
  end

  def handle_event("inc_temperature", _params, socket) do
    {:noreply, update(socket, :temperature, &(&1 + 1))}
  end
end
