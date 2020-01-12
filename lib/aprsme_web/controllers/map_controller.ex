defmodule AprsmeWeb.MapController do
  use AprsmeWeb, :controller

  plug(:put_layout, "map.html")

  def index(conn, _params) do
    ip = to_string(:inet.ntoa(conn.remote_ip))
    IO.inspect(ip)

    with %{
           city: %Geolix.Adapter.MMDB2.Result.City{
             city: city,
             country: country,
             location: %Geolix.Adapter.MMDB2.Record.Location{
               latitude: latitude,
               longitude: longitude
             }
           }
         } <- Geolix.lookup(ip) do
      render(conn, "index.html", coords: %{longitude: longitude, latitude: latitude})
    else
      _ ->
        render(conn, "index.html", coords: %{latitude: 33.035359, longitude: -96.686845})
    end
  end
end
