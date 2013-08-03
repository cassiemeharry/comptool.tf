defmodule Comptool.PluginReceiver do
  use GenServer.Behaviour

  def start_link(port) do
    :gen_server.start_link({ :local, :plugin_receiver }, __MODULE__, port, [])
  end

  def init(port) do
    case :gen_udp.open(port, mode: :binary, reuseaddr: true, active: true) do
      { :ok, socket } ->
        mapping = HashDict.new
        IO.puts "Listening for server streams on port #{port}"
        { :ok, { socket, mapping } }
      { :error, :eaddrinuse } ->
        { :stop, "UDP port #{port} is taken. Ensure that Comptool isn't already running or try a different port." }
    end
  end

  def handle_cast({:register_listener, from_ip, receiver}, {socket, mapping}) when is_binary(from_ip) and is_pid(receiver) do
    workers = [receiver | Dict.get(mapping, from_ip, [])] |> Enum.uniq
    { :noreply, { socket, Dict.put(mapping, from_ip, workers) } }
  end

  def handle_cast({:unregister_listener, from_ip, receiver}, {socket, mapping}) when is_binary(from_ip) and is_pid(receiver) do
    new_mapping = if Dict.has_key?(mapping, from_ip) do
      workers = mapping[from_ip] |> Enum.reject(&1 == receiver)
      if length(workers) do
        Dict.put(mapping, from_ip, workers)
      else
        Dict.delete(mapping, from_ip)
      end
    end
    { :noreply, { socket, new_mapping } }
  end

  def handle_info({:udp, socket, from_ip, _from_port, data}, {socket, mapping}) do
    from_ip = erl_ip_to_binary(from_ip)
    case Dict.get(mapping, from_ip) do
      nil -> nil # Drop packets that aren't being listened for
      socket_workers ->
        case JSON.decode(data) do
          { :ok, parsed } ->
            json = hashdict_to_keyword parsed
            socket_workers |> Enum.each(fn (worker) -> worker <- { :from_plugin, json } end)
            :ok
          { :error, _ } ->
            nil
        end
    end

    { :noreply, {socket, mapping} }
  end

  defp erl_ip_to_binary({a,b,c,d}), do: "#{a}.#{b}.#{c}.#{d}"

  defp hashdict_to_keyword(hd) when is_record(hd, HashDict) do
    Keyword.new(hd, function do
      {k, v} when is_record(v, HashDict) -> {binary_to_atom(k), hashdict_to_keyword(v)}
      {k, v} -> {binary_to_atom(k), v}
    end)
  end

  defp hashdict_to_keyword(otherwise), do: otherwise
end
