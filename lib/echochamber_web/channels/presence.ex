defmodule EchochamberWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  alias Echochamber.Accounts

  use Phoenix.Presence,
    otp_app: :echochamber,
    pubsub_server: Echochamber.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      {key, %{metas: [meta | metas], id: meta.id, user: Accounts.get_user!(meta.id)}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(Echochamber.PubSub, "proxy:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(Echochamber.PubSub, "proxy:#{topic}", msg)
    end

    {:ok, state}
  end

  def list_online_users(),
    do: list("online_users") |> Enum.map(fn {_id, presence} -> presence end)

  def list_profile_users(profile),
    do: list(profile) |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(topic, name, params), do: track(self(), topic, name, params)

  def subscribe(topic), do: Phoenix.PubSub.subscribe(Echochamber.PubSub, "proxy:#{topic}")
end
