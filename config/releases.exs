import Config

config :aprsme,
  purge_packet_count: System.fetch_env!("PACKET_PURGE_COUNT") || 1,
  purge_packet_interval: System.fetch_env!("PACKET_PURGE_INTERVAL") || "hour"

config :aprsme,
  rabbitmq_url: System.fetch_env!("RABBITMQ_URL")

config :aprsme, AprsmeWeb.Endpoint, secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :aprsme, Aprsme.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.fetch_env!("POOL_SIZE") || "10"),
  timeout: 60000
