# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :previously,
  ecto_repos: [Previously.Repo]

# Configures the endpoint
config :previously, PreviouslyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hcc2OylOm4Ss0ko6zLQGDLlKJjKWqCHNApzyGFl0TF6sDYoaE856yLYuQqXDfYTI",
  render_errors: [view: PreviouslyWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Previously.PubSub,
  live_view: [signing_salt: "LEGf6xZm"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Pow config
config :previously, :pow,
  user: Previously.Users.User,
  repo: Previously.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
