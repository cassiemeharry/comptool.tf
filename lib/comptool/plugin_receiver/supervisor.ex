defmodule Comptool.PluginReceiver.Supervisor do
  use Supervisor.Behaviour

  def start_link(nil) do
    :supervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    port = Comptool.Settings.get([:web, :plugin_udp_port])
    workers = [ worker(Comptool.PluginReceiver, [port]) ]
    supervise(workers, strategy: :one_for_one)
  end
end
