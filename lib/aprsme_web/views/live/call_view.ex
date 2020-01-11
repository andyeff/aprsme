defmodule AprsmeWeb.CallView do
  use Phoenix.LiveView
  require Logger
  alias Phoenix.Socket.{Broadcast}

  @topic "call"

  def render(assigns) do
    AprsmeWeb.PageView.render("call.html", assigns)
  end

  def mount(session, socket) do
    AprsmeWeb.Endpoint.subscribe(@topic)

    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    IO.inspect(session)
    # if connected?(socket) do
    #   Phoenix.PubSub.subscribe(LiveviewDemo.PubSub, @topic)
    # end

    time = NaiveDateTime.utc_now()

    socket =
      socket
      |> assign(:time, time)
      |> assign(:packets, [])
      |> assign(:callsign, session["callsign"])

    {:ok, socket}
  end

  def handle_info({:call_update, payload}, socket) do
    if payload["srccallsign"] == socket.assigns[:callsign] do
      updated_packets = socket.assigns[:packets] ++ [payload["origpacket"]]

      socket =
        socket
        |> assign(:packets, updated_packets)

      IO.inspect(socket.assigns)
    end

    {:noreply, socket}
  end

  @spec handle_info(:tick, Phoenix.LiveView.Socket.t()) :: {:noreply, any}
  def handle_info(:tick, socket) do
    {:noreply, handle_tick(socket)}
  end

  defp handle_tick(socket) do
    time = NaiveDateTime.utc_now()
    assign(socket, :time, time)
  end
end
