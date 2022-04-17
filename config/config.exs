# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :coin_gecko, CoinGeckoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: CoinGeckoWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CoinGecko.PubSub,
  live_view: [signing_salt: "MOOFVF9P"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :coin_gecko,
  messenger_profile_api: "https://graph.facebook.com/v13.0/me/messenger_profile",
  messages: "https://graph.facebook.com/v13.0/me/messages",
  graph: "https://graph.facebook.com"

config :coin_gecko,
  webhook_token:
    "EAAGt2prq0X8BAOsqyo0XRRGstJIthFcjnAjJJaHwxUWgds7PyLsByMDZBsdburgGr2cveGVfZCi3UZBH2D4ZC1cjHbj9vRB6DQmMjVX4m7ievj2DHIRzf7WNbtZCBm7HGGoBLhs2sqqvATbZBNORYzGb9fXOu8LmaQOo97OufnvMyZAEKj7K8Dw"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
