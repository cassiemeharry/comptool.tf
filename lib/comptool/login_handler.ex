defmodule CompTool.LoginHandler do
  def init(_transport, req, config) do
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

    {ids, req} = CompTool.Util.Auth.ensure_id(req, steam_id)
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
    openid_url = CompTool.Util.build_url_with_querystring(
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

  def terminate(_reason, _req, _config) do
    :ok
  end
end
