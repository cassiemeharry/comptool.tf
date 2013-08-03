defmodule Comptool.Supervisor do
  use Supervisor.Behaviour

  def start_link(nil) do
    :supervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    tree = [
        supervisor(Comptool.Dynamo, [[max_restarts: 5, max_seconds: 5]]),
        supervisor(Comptool.PluginReceiver.Supervisor, [2667]),
    ]
    supervise(tree, strategy: :one_for_one)
  end
end
