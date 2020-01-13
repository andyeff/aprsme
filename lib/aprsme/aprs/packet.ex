defmodule Aprsme.Aprs.Packet do
  @default_srid 4326

  # This drives JSON encoding
  @derive {Jason.Encoder,
           only: [:latitude, :longitude, :srccallsign, :symboltable, :symbolcode, :type, :status]}

  import Ecto.Changeset
  import Ecto.Query
  import Geo.PostGIS

  use Ecto.Schema
  use AprsmeWeb.Model
  alias Aprsme.Repo

  def data() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, params) do
    case Map.get(params, :order_by) do
      nil -> queryable
      order_by -> from record in queryable, order_by: ^order_by
    end
  end

  def find(id) do
    Packet |> Repo.get(id)
  end

  @spec recent(any) :: Ecto.Query.t()
  def recent(query) do
    from(q in query,
      order_by: [desc: q.inserted_at]
    )
  end

  @spec recent_by_callsign(any, any) :: Ecto.Query.t()
  def recent_by_callsign(query, callsign) do
    from(q in query,
      select: q,
      where: q.srccallsign == ^callsign,
      order_by: [desc: q.inserted_at]
    )
  end

  # See: https://hexdocs.pm/ecto/Ecto.Query.API.html#ago/2
  @spec older_than(any, number | Decimal.t(), any) :: Ecto.Query.t()
  def older_than(query, purge_count \\ 1, purge_interval \\ "day") do
    from(q in query,
      where: q.inserted_at < ago(^purge_count, ^purge_interval)
    )
  end

  @spec newer_than_n_minutes_ago(any, integer) :: Ecto.Query.t()
  def newer_than_n_minutes_ago(query, minutes_ago) do
    as_of_date = Timex.subtract(Timex.now(), Timex.Duration.from_minutes(minutes_ago))

    inserted_on_or_after(query, as_of_date)
  end

  @spec for_callsigns(any, any) :: Ecto.Query.t()
  def for_callsigns(query, callsigns) do
    from(q in query,
      where: q.srccallsign in ^callsigns
    )
  end

  @spec distinct_callsigns(any, map, map) :: Ecto.Query.t()
  def distinct_callsigns(query, ne, sw) do
    from(q in query,
      select: q.srccallsign,
      distinct: true,
      where: st_contains(^bbox_from_corners(ne, sw), q.point)
    )
  end

  @spec inserted_on_or_after(any, any) :: Ecto.Query.t()
  def inserted_on_or_after(query, as_of_date) do
    from(q in query,
      where: q.inserted_at >= ^as_of_date
    )
  end

  @spec by_insertion_time(any) :: Ecto.Query.t()
  def by_insertion_time(query) do
    from(q in query,
      order_by: [asc: q.inserted_at]
    )
  end

  @spec within_bbox(any, map, map) :: Ecto.Query.t()
  def within_bbox(query, ne, sw) do
    # select unique set of callsigns from all packets occurring within the bbox
    # then select all packets from those callsigns
    from(q in query,
      select: q,
      order_by: [asc: q.inserted_at],
      group_by: [q.srccallsign, q.id],
      where: st_contains(^bbox_from_corners(ne, sw), q.point)
    )
  end

  defp bbox_from_corners(%{"lng" => x1, "lat" => y1}, %{"lng" => x2, "lat" => y2}) do
    %Geo.Polygon{
      coordinates: [[{x1, y1}, {x1, y2}, {x2, y2}, {x2, y1}, {x1, y1}]],
      srid: @default_srid
    }
  end

  schema "packets" do
    field(:point, Geo.PostGIS.Geometry)

    field(:alive, :integer)
    field(:altitude, :float)
    field(:body, :binary)
    field(:capabilities, :string)
    field(:checksumok, :integer)
    field(:comment, :string)
    field(:course, :integer)
    field(:daodatumbyte, :string)
    field(:destination, :string)
    # field :digipeaters, :text
    field(:dstcallsign, :string)
    field(:dxcall, :string)
    field(:dxfreq, :string)
    field(:dxinfo, :string)
    field(:dxsource, :string)
    field(:dxtime, :string)
    field(:format, :string)
    field(:gpsfixstatus, :integer)
    field(:header, :string)
    field(:itemname, :string)
    field(:latitude, :float)
    field(:longitude, :float)
    field(:mbits, :string)
    field(:message, :string)
    field(:messageack, :string)
    field(:messageid, :string)
    field(:messagerej, :string)
    field(:messaging, :integer)
    field(:objectname, :string)
    field(:origpacket, :binary)
    field(:type, :string)
    field(:phg, :integer)
    field(:posambiguity, :integer)
    field(:posresolution, :float)
    field(:radiorange, :float)
    field(:resultcode, :string)
    field(:resultmsg, :string)
    field(:speed, :float)
    field(:srccallsign, :string)
    field(:status, :string)
    field(:symbolcode, :string)
    field(:symboltable, :string)
    field(:telemetry, :binary)
    field(:timestamp, :utc_datetime)
    # field :wx, :string

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(packet, params \\ %{}) do
    packet
    |> cast(params, [
      :point,
      :alive,
      :altitude,
      :body,
      :checksumok,
      :comment,
      :course,
      :daodatumbyte,
      :destination,
      :dstcallsign,
      :dxcall,
      :dxfreq,
      :dxinfo,
      :dxsource,
      :dxtime,
      :format,
      :gpsfixstatus,
      :header,
      :itemname,
      :latitude,
      :longitude,
      :mbits,
      :message,
      :messageack,
      :messageid,
      :messagerej,
      :messaging,
      :objectname,
      :origpacket,
      :type,
      # :phg,
      :posambiguity,
      :posresolution,
      :radiorange,
      :resultcode,
      :resultmsg,
      :speed,
      :srccallsign,
      :status,
      :symbolcode,
      :symboltable
      # :telemetry,
    ])
  end
end
