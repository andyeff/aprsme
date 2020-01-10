defmodule Aprsme.IncomingPacketSupervisor do
  use Supervisor

  # public API
  @spec start_link :: none
  def start_link() do
    Supervisor.start_link(__MODULE__, [], restart: :permanent, name: __MODULE__)
  end

  # callbacks
  @spec init(any) :: {:ok, {{any, any, any}, any}}
  def init(_) do
    children = [
      worker(Aprsme.WebsocketWorker, []),
      worker(Aprsme.ArchiveWorker, [])
    ]

    opts = [strategy: :one_for_one]

    supervise(children, opts)
  end
end
