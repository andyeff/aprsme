defmodule AprsmeWeb.Router do
  use AprsmeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug Phoenix.LiveView.Flash
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    if Application.get_env(:aprsme, :force_ssl) do
      plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
    end
  end

  pipeline :api do
    plug(:accepts, ["json"])

    if Application.get_env(:aprsme, :force_ssl) do
      plug(Plug.SSL, rewrite_on: [:x_forwarded_proto], host: nil)
    end
  end

  scope "/", AprsmeWeb do
    pipe_through([:browser])

    get("/", MapController, :index)

    resources("/packets", PacketController, only: [:show])
    resources("/call", CallController, only: [:show])
  end
end
