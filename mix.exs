defmodule Aprsme.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aprsme,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Aprsme.Application, []},
      extra_applications: [:logger, :runtime_tools, :retry]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.11"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_view, "~> 0.4.1"},
      #{:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:floki, ">= 0.0.0", only: :test},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, ">= 0.0.0"},
      {:instream, "~> 0.22.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:amqp, "~> 1.1"},
      {:credo, "~> 1.1.5", only: [:dev, :test], runtime: false},
      {:coveralls, "~> 2.0", only: [:dev, :test], runtime: false},
      {:timex, "~> 3.4"},
      {:geo, "~> 3.0"},
      {:geo_postgis, "~> 3.3.1"},
      {:scrivener_ecto, "~> 2.2.0"},
      {:scrivener_html, "~> 1.8.1"},
      {:quantum, "~> 2.3"},
      {:retry, "~> 0.13.0"},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
