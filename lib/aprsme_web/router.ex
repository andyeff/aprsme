defmodule AprsmeWeb.Router do
  use AprsmeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug Phoenix.LiveView.Flash
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AprsmeWeb do
    pipe_through([:browser])

    get("/", MapController, :index)

    resources("/packets", PacketController, only: [:show])
    resources("/call", CallController, only: [:show])
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: AprsmeWeb.Schema
  end
end
