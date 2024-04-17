defmodule Ploty.Repo do
  use Ecto.Repo,
    otp_app: :ploty,
    adapter: Ecto.Adapters.Postgres
end
