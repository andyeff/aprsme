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

    # if connected?(socket) do
    #   Phoenix.PubSub.subscribe(LiveviewDemo.PubSub, @topic)
    # end

    time = NaiveDateTime.utc_now()
    socket = socket
      |> assign(:time, time)
    {:ok, socket}
  end

  # def handle_info(:get_addresses, socket) do
  #   addresses = Wispetc.Sonar.Addresses.get_by_account(socket.assigns[:account]["id"])
  #   socket =
  #     socket
  #       |> assign(:addresses, hd(addresses))
  #   {:noreply, socket}
  # end

  def handle_info(%Phoenix.Socket.Broadcast{topic: @topic, payload: state}, socket) do
    IO.puts "HANDLE BROADCAST FOR #{state[:call]}"
    {:noreply, assign(socket, state)}
  end

  def handle_info(:tick, socket) do
    {:noreply, handle_tick(socket)}
  end
  defp handle_tick(socket) do
    time = NaiveDateTime.utc_now()
    assign(socket, :time, time)
  end
end
