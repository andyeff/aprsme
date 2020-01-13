defmodule AprsmeWeb.CallView do
  use Phoenix.LiveView
  require Logger
  alias Phoenix.Socket.Broadcast
  alias Aprsme.Aprs.Packet
  alias Aprsme.Repo

  @topic "call"

  def render(assigns) do
    AprsmeWeb.PageView.render("call.html", assigns)
  end

  def mount(session, socket) do
    AprsmeWeb.Endpoint.subscribe("#{@topic}:#{session[:callsign]}")
    # if connected?(socket) do
    #   :timer.send_interval(1000, self(), :tick)
    # end

    # if connected?(socket) do
    #   Phoenix.PubSub.subscribe(LiveviewDemo.PubSub, @topic)
    # end

    time = NaiveDateTime.utc_now()

    socket =
      socket
      |> assign(:time, time)
      |> assign(:packets, session[:packets])
      |> assign(:callsign, session[:callsign])

    {:ok, socket}
  end

  def handle_info({:call_update, payload}, socket) do
    # updated_packets = socket.assigns[:packets] ++ [payload["origpacket"]]
    updated_packets =
      Packet
      |> Packet.recent_by_callsign(socket.assigns[:callsign])
      |> Repo.paginate()

    socket =
      socket
      |> assign(:packets, updated_packets)

    # IO.inspect(socket.assigns)

    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    {:noreply, handle_tick(socket)}
  end

  defp handle_tick(socket) do
    time = NaiveDateTime.utc_now()
    assign(socket, :time, time)
  end
end
