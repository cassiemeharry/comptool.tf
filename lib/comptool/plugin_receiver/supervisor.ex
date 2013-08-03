defmodule Comptool.PluginReceiver.Supervisor do
  use Supervisor.Behaviour

  def start_link(port) do
    :supervisor.start_link(__MODULE__, port)
  end

  def init(port) do
    workers = [ worker(Comptool.PluginReceiver, [port]) ]
    supervise(workers, strategy: :one_for_one)
  end
end
