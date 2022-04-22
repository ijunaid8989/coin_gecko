import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :coin_gecko, CoinGeckoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "b1OHkr7cDKTL4VqGhsmFjdOAUSbCgEonWyAsDysrhFkd608YT7Csof9SurIpquS+",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :coin_gecko,
  webhook_token: "token"

config :coin_gecko,
  bot_messaging: CoinGecko.Bot.Local,
  api_wrapper: CoinGecko.API.Local
