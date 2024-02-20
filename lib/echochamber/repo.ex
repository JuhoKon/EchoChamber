defmodule Echochamber.Repo do
  use Ecto.Repo,
    otp_app: :echochamber,
    adapter: Ecto.Adapters.Postgres
end
