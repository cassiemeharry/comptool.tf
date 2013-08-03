defmodule Comptool.Websocket.Manager do
  use GenServer.Behaviour

  def start_link({port, supervisor}) do
    :gen_server.start_link(__MODULE__, {port, supervisor}, [])
  end

  def init({port, supervisor}) do
    { :ok, socket } = Socket.Web.listen(port)
    IO.puts "Listening for WebSocket connections on port #{port}"

    listener = spawn_link(__MODULE__, :accept_loop, [socket, supervisor])
    { :ok, listener }
  end

  def accept_loop(server_socket, supervisor) do
    client_socket = server_socket.accept!
    client_handler = Supervisor.Behaviour.worker(Comptool.Websocket.Worker, [client_socket], id: client_socket, restart: :transient)
    { :ok, _child } = :supervisor.start_child(supervisor, client_handler)
    accept_loop(server_socket, supervisor)
  end
end
