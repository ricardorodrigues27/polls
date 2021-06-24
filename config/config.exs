# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :payfy_enquetes,
  ecto_repos: [PayfyEnquetes.Repo]

config :payfy_enquetes, :generators,
  migration: true,
  binary_id: true

# Configures the endpoint
config :payfy_enquetes, PayfyEnquetesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Nk+bbzHPV79lxUCoaCzQyCfFjq+cDfj6gBmnM0FwBin3rjLrpoNGi4vnAyK72cUq",
  render_errors: [view: PayfyEnquetesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PayfyEnquetes.PubSub,
  live_view: [signing_salt: "/hU8imUm"]

config :payfy_enquetes, PayfyEnquetes.Repo,
  migration_primary_key: [name: :id, type: :uuid],
  migration_timestamps: [type: :utc_datetime]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
