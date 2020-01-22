defmodule AprsmeWeb.PacketResolver do
  alias Aprsme.Aprs.Packet
  alias Aprsme.Repo

  def show(_parent, args, _resolutions) do
    case Packet.find(args[:id]) do
      nil -> {:error, "Not found"}
      packet -> {:ok, packet}
    end
  end

  def all(_args, _info) do
    {:ok, Aprsme.Repo.all(Packet)}
  end

  def find(%{srccallsign: srccallsign} = args, _info) do
    packets = Packet |> Packet.recent_by_callsign(srccallsign) |> Repo.all
    {:ok, packets}
  end

  def find(%{id: id} = args, _info) do
    packets = Packet.find(id)
    {:ok, packets}
  end

end