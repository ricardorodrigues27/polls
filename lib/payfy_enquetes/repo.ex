defmodule PayfyEnquetes.Repo do
  use Ecto.Repo,
    otp_app: :payfy_enquetes,
    adapter: Ecto.Adapters.Postgres
end
