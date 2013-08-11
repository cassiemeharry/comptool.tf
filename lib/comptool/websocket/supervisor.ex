defmodule Comptool.Websocket.Supervisor do
  use Supervisor.Behaviour

  def start_link(nil) do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, nil)
  end

  def init(nil) do
    port = Comptool.Settings.get([:web, :websocket_tcp_port])
    manager = worker(Comptool.Websocket.Manager, [{port, self()}])
    supervise([manager], strategy: :one_for_one)
  end
end
