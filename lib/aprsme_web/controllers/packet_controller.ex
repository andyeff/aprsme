defmodule AprsmeWeb.PacketController do
  use AprsmeWeb, :controller

  alias Aprsme.Aprs.Packet
  alias Aprsme.Repo

  def index(conn, params) do
    page =
      Packet
      |> Packet.recent()
      |> Repo.paginate(params)

    render(conn, "index.html", page: page)
  end

  def show(conn, %{"id" => id}) do
    packet = Repo.get!(Packet, id)
    render(conn, "show.html", packet: packet)
  end
end
