import Config

# config :aprsme,
#   purge_packet_count: String.to_integer(System.get_env("PACKET_PURGE_COUNT")) || 1,
#   purge_packet_interval: System.get_env("PACKET_PURGE_INTERVAL") || "hour"

config :aprsme,
  rabbitmq_url: System.fetch_env!("RABBITMQ_URL")

config :aprsme, AprsmeWeb.Endpoint, secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :aprsme, Aprsme.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.fetch_env!("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  timeout: 60000

config :aprsme, force_ssl: true

config :aprsme, AprsmeWeb.Endpoint,
  url: [host: "https://aprs.me"],
  check_origin: ["//aprs.me"],
  https: [:inet6,
    port: 443,
    keyfile: System.fetch_env!("SSL_KEY_PATH"),
    certfile: System.fetch_env!("SSL_CERT_PATH")]
