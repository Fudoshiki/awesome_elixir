# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :awesome_elixir, AwesomeElixirWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4i510y6TLiKLBESdfK0FI9YezrHMbvpWGtEKp/sU2vi3d+ozitv99iuApUi8tQyj",
  render_errors: [view: AwesomeElixirWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AwesomeElixir.PubSub,
  live_view: [signing_salt: "qYT6/yUA"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: Tesla.Adapter.Hackney

config :awesome_elixir,
  github_auth_token: System.get_env("GITHUB_AUTH_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
