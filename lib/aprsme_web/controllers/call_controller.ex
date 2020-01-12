defmodule AprsmeWeb.CallController do
  use AprsmeWeb, :controller
  alias Phoenix.LiveView

  alias Aprsme.Repo
  alias Aprsme.Aprs.{Packet}

  def show(conn, %{"id" => id} = params) do
    callsign = String.upcase(id)
    packets =
      Packet
      |> Packet.recent_by_callsign(callsign)
      |> Repo.paginate(params)
    conn
    |> LiveView.Controller.live_render(AprsmeWeb.CallView,
      session: %{callsign: callsign, packets: packets}
    )
  end
end
