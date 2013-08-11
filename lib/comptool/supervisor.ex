defmodule Comptool.Supervisor do
  use Supervisor.Behaviour

  def start_link(nil) do
    :supervisor.start_link(__MODULE__, nil)
  end

  def init(nil) do
    settings_filename = Path.expand("../../priv/settings.yml", __DIR__)
    { :ok, [settings] } = :yaml.load_file(settings_filename, [:implicit_atoms])

    tree = [
        supervisor(Comptool.Dynamo, [[max_restarts: 5, max_seconds: 5]]),
        worker(Comptool.Settings, [settings]),
        supervisor(Comptool.PluginReceiver.Supervisor, [settings[:web][:plugin_udp_port]]),
        supervisor(Comptool.Websocket.Supervisor, [settings[:web][:websocket_tcp_port]]),
    ]
    supervise(tree, strategy: :one_for_one)
  end
end
