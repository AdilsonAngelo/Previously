defmodule Previously.Repo do
  use Ecto.Repo,
    otp_app: :previously,
    adapter: Ecto.Adapters.Postgres
end
