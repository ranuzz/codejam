defmodule Codejam.Repo do
  use Ecto.Repo,
    otp_app: :codejam,
    adapter: Ecto.Adapters.Postgres
end
