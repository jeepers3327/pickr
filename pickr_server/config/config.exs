# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pickr,
  ecto_repos: [Pickr.Repo]

# Configures the endpoint
config :pickr, PickrWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AkFVVPHEsfwCRP/41yWqTL9U6JEEduRJT5/JXCVjwwvRZ+9PvUBqQ24kxMpDyLSl",
  render_errors: [view: PickrWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pickr.PubSub,
  live_view: [signing_salt: "uabxMdRY"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: ["https://pickr.vercel.app", "http://localhost:4000"],
  max_age: 86400,
  methods: ["GET", "POST"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
