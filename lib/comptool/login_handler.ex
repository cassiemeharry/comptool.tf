defmodule CompTool.LoginHandler do
  def init(_transport, req, config) do
    IO.inspect(config)
    {:ok, req, config}
  end

  def handle(req, config) do
    {path_info, req} = :cowboy_req.path(req)
    cond do
      path_info == "/login" ->
        handle_login_step_1(req, config)
      path_info == "/login-return" ->
        handle_login_step_2(req, config)
    end
  end

  defp handle_login_step_2(req, config) do
    {qd, req} = :cowboy_req.qs_vals(req)
    # Enum.each(qd, fn (x) -> IO.inspect(x) end)
    steam_id = get_steam_id_from_querydict(qd)

    {ids, req} = ensure_id(req, steam_id)
    IO.inspect(ids)

    {:ok, req} = :cowboy_req.reply(302, [{"location", "/"}], "Thanks for logging in. Redirecting you back to the app.", req)
    {:ok, req, config}
  end

  defp get_steam_id_from_querydict([]) do
    nil
  end
  defp get_steam_id_from_querydict([{k, v} | rest]) do
    if k == "openid.claimed_id" do
      String.split(v, "/") |> List.last
    else
      get_steam_id_from_querydict(rest)
    end
  end

  defp handle_login_step_1(req, config) do
    openid_url = build_url_with_querystring(
      "http://steamcommunity.com/openid/login",
      [
        {"openid.ns", "http://specs.openid.net/auth/2.0"},
        {"openid.mode", "checkid_setup"},
        {"openid.return_to", "#{config |> Keyword.get!(:api) |> Keyword.get!(:root)}/login-return"},
        {"openid.realm", config |> Keyword.get!(:auth) |> Keyword.get!(:realm)},
        # {"openid.ns.sreg", "http://openid.net/extensions/sreg/1.1"},
        {"openid.claimed_id", "http://specs.openid.net/auth/2.0/identifier_select"},
        {"openid.identity", "http://specs.openid.net/auth/2.0/identifier_select"}
      ]
    )

    {:ok, req} = :cowboy_req.reply(302, [{"location", openid_url}], "Redirecting you to Steam...", req)
    {:ok, req, config}
  end

  defp build_url_with_querystring(url, dict) do
    qs = build_querystring(dict) |> Enum.join
    qs = String.slice(qs, 1, String.length(qs) - 1)
    "#{url}?#{qs}"
  end

  defp build_querystring([]) do
    []
  end
  defp build_querystring([{k, v} | rest]) do
    encoded = binary_to_list(v) |> :edoc_lib.escape_uri |> list_to_binary
    chunk = "&#{k}=#{encoded}"
    [chunk | build_querystring(rest)]
  end

  defp ensure_id(req, steam_override // nil) do
    {session, req} = :cowboy_session.get(req)
    if ! Keyword.keyword?(session) do
      session = Keyword.new()
    end

    ids = Keyword.get(session, :ids, [])
    local = Keyword.get(ids, :local)
    steam = Keyword.get(ids, :steam)

    if steam_override != nil do
      steam = steam_override
      ids = Keyword.put(ids, :steam, steam)
    end
    if local == nil do
      local = :random.uniform(1000000)
      ids = Keyword.put(ids, :local, local)
    end

    session = Keyword.merge(session, [ids: ids])
    req = :cowboy_session.set(session, req)

    {ids, req}
  end

  def terminate(_reason, _req, _config) do
    :ok
  end
end
