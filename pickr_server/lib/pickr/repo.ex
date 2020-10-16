defmodule Pickr.Repo do
  use Ecto.Repo,
    otp_app: :pickr,
    adapter: Ecto.Adapters.Postgres
end
