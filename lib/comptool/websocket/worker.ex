defmodule Comptool.Websocket.Worker do
  use GenServer.Behaviour

  def start_link(client_socket) do
    :gen_server.start_link(__MODULE__, client_socket, [])
  end

  def init(client_socket) do
    client_socket.accept!
    spawn_link(__MODULE__, :start_listen_loop, [client_socket, self()])

    { :ok, { client_socket, nil } }
  end

  def start_listen_loop(client_socket, parent) do
    { :ok, { :text, ip_addr } } = client_socket.recv
    parent <- { :set_ip, ip_addr }
    listen_loop(client_socket, parent)
  end

  def listen_loop(client_socket, parent) do
    case client_socket.recv do
      { :ok, data } ->
        parent <- { :from_client, data }
        listen_loop(client_socket, parent)
      { :error, _error } ->
        client_socket.close
        parent <- :client_closed
      otherwise ->
        IO.puts "got unexpected message from client: #{inspect otherwise}"
        client_socket.close
        parent <- :client_closed
    end
  end

  def handle_info(:client_closed, state) do
    { :stop, :normal, state }
  end

  def handle_info({ :from_client, _json }, state) do
    { :noreply, state }
  end

  def handle_info({ :from_plugin, json }, { client_socket, watching_ip }) do
    client_socket.send { :text, JSON.encode(json) }

    { :noreply, { client_socket, watching_ip } }
  end

  def handle_info({ :set_ip, watching_ip }, { client_socket, nil }) do
    :gen_server.cast :plugin_receiver, { :register_listener, watching_ip, self() }
    { :noreply, { client_socket, watching_ip } }
  end

  def handle_info({ :set_ip, watching_ip }, { client_socket, old_ip }) do
    :gen_server.cast :plugin_receiver, { :unregister_listener, old_ip, self() }
    handle_info({ :set_ip, watching_ip }, { client_socket, nil })
  end

  def handle_info(msg, state) do
    IO.puts "Unknown message in websocket worker #{inspect self()}: #{inspect msg}"
    { :noreply, state }
  end

  def terminate(_reason, { _client_socket, watching_ip }) do
    if watching_ip do
      :gen_server.cast :plugin_receiver, { :unregister_listener, watching_ip, self() }
    end
    :ok
  end
end