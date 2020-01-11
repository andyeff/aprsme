use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :aprsme, AprsmeWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :aprsme, Aprsme.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "aprsme_test",
  hostname: "localhost",
  port: 25432,
  pool: Ecto.Adapters.SQL.Sandbox
