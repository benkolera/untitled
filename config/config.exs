# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :untitled,
  ecto_repos: [Untitled.Repo]

# Configures the endpoint
config :untitled, UntitledWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q5Dp7VdHzya38XVPSyCPaODkWIYWDpw4FUtmAgBuNhQVmdvv0qYkIMINMujc6f5W",
  render_errors: [view: UntitledWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Untitled.PubSub,
  live_view: [signing_salt: "dnRUz/e9"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
