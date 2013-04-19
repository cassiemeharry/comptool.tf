defmodule CompTool.API.User do
  def init(_transport, req, config) do
    {:ok, req, config}
  end

  def handle(req, config) do
    {ids, req} = CompTool.Util.Auth.ensure_id(req)
    resp = Keyword.new()

    steam = Keyword.get(ids, :steam)
    if Keyword.get(ids, :steam) != nil do
      resp = Keyword.put(resp, :loggedIn, true)
      resp = Keyword.put(resp, :steamId, steam)
      resp = get_player_info(resp, steam, config)
    else
      resp = Keyword.put(resp, :loggedIn, false)
    end

    {sid, req} = :cowboy_req.cookie("sid", req, nil)
    _ = CompTool.Util.Session.get(sid)

    {:ok, req} = CompTool.Util.json_response(resp, req)
    {:ok, req, config}
  end

  defp get_player_info(resp, steam_id, config) do
    player_summary_url = CompTool.Util.build_url_with_querystring(
      "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/",
      [
       key: config |> Keyword.get!(:auth) |> Keyword.get!(:steam_api_key),
       steamids: steam_id,
      ],
    ) |> binary_to_list
    {:ok, '200', _headers, raw_response} = :ibrowse.send_req(player_summary_url, [], :get)

    steam_info = list_to_binary(raw_response)
      |> :jsx.decode
      |> CompTool.Util.string_dict_to_kw_list
      |> Keyword.get!(:response)
      |> Keyword.get!(:players)
      |> Enum.first

    Keyword.put(resp, :steamInfo, steam_info)
  end

  def terminate(_reason, _req, _config) do
    :ok
  end
end
