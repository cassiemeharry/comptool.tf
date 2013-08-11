defmodule Comptool.Supervisor do
  use Supervisor.Behaviour

  def start_link(nil) do
    :supervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    tree = [
        worker(Comptool.Settings, [nil]),
        supervisor(Comptool.Dynamo, [[max_restarts: 5, max_seconds: 5]]),
        supervisor(Comptool.PluginReceiver.Supervisor, [nil]),
        supervisor(Comptool.Websocket.Supervisor, [nil]),
    ]
    supervise(tree, strategy: :one_for_one)
  end
end
