defmodule CompTool.LoginHandler do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    {session, req} = :cowboy_session.get(req)
    IO.inspect(session)
    req = :cowboy_session.set(:something_else, req)
    {:ok, req} = :cowboy_req.reply(200, [], "Hello world!", req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end
end
