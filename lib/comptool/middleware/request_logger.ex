defmodule CompTool.Middleware.RequestLogger do
  @behaviour :cowboy_middleware

  def execute(req, env) do
    req = try do
      {{{a,b,c,d}, _}, req} = :cowboy_req.peer(req)
      {method, req} = :cowboy_req.method(req)
      {path, req} = :cowboy_req.path(req)
      {{x, y}, req} = :cowboy_req.version(req)
      IO.puts("#{a}.#{b}.#{c}.#{d} - \"#{method} #{path} HTTP/#{x}.#{y}\"")
      req
    catch
      _ -> req
    end

    {:ok, req, env}
  end
end
