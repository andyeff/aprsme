use Mix.Config

config :aprsme, AprsmeWeb.Endpoint,
  load_from_system_env: true,
  cache_static_manifest: "priv/static/static_manifest.json"

# Do not print debug messages in production
config :logger, level: :info
config :phoenix, :serve_endpoints, true

config :geolix,
  databases: [
    %{
      id: :city,
      adapter: Geolix.Adapter.MMDB2,
      source: "/data/geoip/GeoLite2-City.mmdb"
    },
    %{
      id: :country,
      adapter: Geolix.Adapter.MMDB2,
      source: "/data/geoip/GeoLite2-Country.mmdb"
    }
  ]

# check_origin must be specified to enable WebSockets to work
config :aprsme, AprsmeWeb.Endpoint,
  #url: [host: "https://aprs.me"],
  check_origin: ["//aprs.me"]

import_config "prod.secret.exs"
