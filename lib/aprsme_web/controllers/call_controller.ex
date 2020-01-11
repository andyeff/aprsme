defmodule AprsmeWeb.CallController do
  use AprsmeWeb, :controller
  alias Phoenix.LiveView

  alias Aprsme.Repo
  alias Aprsme.Aprs.Packet

  def show(conn, %{"id" => id} = params) do
    # page =
    #   Packet
    #   |> Packet.recent_by_callsign(id)
    #   |> Repo.paginate(params)

    # render(conn, "show.html", page: page, callsign: id)
    conn
    |> LiveView.Controller.live_render(AprsmeWeb.CallView,
      session: %{"callsign" => String.upcase(id)}
    )
  end
end
