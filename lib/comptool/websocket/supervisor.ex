defmodule Comptool.Websocket.Supervisor do
  use Supervisor.Behaviour

  def start_link(port) do
    :supervisor.start_link({:local, __MODULE__}, __MODULE__, port)
  end

  def init(port) do
    manager = worker(Comptool.Websocket.Manager, [{port, self()}])
    supervise([manager], strategy: :one_for_one)
  end
end
