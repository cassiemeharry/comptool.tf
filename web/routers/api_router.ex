defmodule ApiRouter do
  use Dynamo.Router

  defp send_error(conn, code // 400, error, help // "") do
    halt! send(conn, [
      status: "error",
      error: error,
      help: help,
    ], code)
  end

  defp send(conn, data, code // 200) do
    conn.resp(code, JSON.encode data)
  end

  prepare do
    conn = conn.resp_content_type("application/json")
    conn = conn.fetch([:params, :session])

    unless get_session(conn, :steam_id) do
      send_error(conn, 401, "Not logged in",
        "Open a browser to /login and sign in with Steam to get your auth cookie"
      )
    end

    conn
  end

  # /
  #   API Root, verifies login
  # /user
  #   Provide information about the currently logged in user
  # /user/request-access/caster
  #   Send a "request for access" email for the currently logged in account
  # /caster/stream/new
  #   Connect to a specified server, returns a steam ID
  # /caster/stream/:steam_id
  #   Event stream for a given ID
  #   Only the user that established the stream may view
  # /caster/stats/:steam_id
  #   Generate a random stat relevant to the given stream

  get "/" do
    send(conn, [status: "ok"])
  end
end
