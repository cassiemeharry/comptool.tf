defmodule LoginRouter do
  use Dynamo.Router

  get "" do
    web_port = Comptool.Settings.get([:web, :web_tcp_port])
    config = [api: [root: "http://dev.comptool.tf:#{web_port}"], auth: [realm: "comptool.tf"]]
    query_args = [
      {"openid.ns", "http://specs.openid.net/auth/2.0"},
      {"openid.mode", "checkid_setup"},
      {"openid.return_to", config[:api][:root] <> "/login/return"},
      {"openid.realm", config[:auth][:realm]},
      # {"openid.ns.sreg", "http://openid.net/extensions/sreg/1.1"},
      {"openid.claimed_id", "http://specs.openid.net/auth/2.0/identifier_select"},
      {"openid.identity", "http://specs.openid.net/auth/2.0/identifier_select"},
    ] |> URI.encode_query

    redirect conn, to: "http://steamcommunity.com/openid/login?#{String.strip(query_args, ?&)}"
  end

  get "/return" do
    claimed_id = conn.params["openid.claimed_id"] |> String.split("/") |> List.last
    api_key = Comptool.Settings.get [:steam, :api_key]
    query = [key: api_key, steamids: claimed_id]
    api_endpoint = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?#{URI.encode_query query}"
    { :ok, api_response } = HTTPotion.get(api_endpoint).body |> JSON.decode
    api_data = api_response["response"]["players"] |> Enum.at(0)

    steam_info = [steam_id: api_data["steamid"], name: api_data["personaname"], avatar: api_data["avatar"]]

    conn = put_session(conn, :steam_info, steam_info)

    user = Comptool.DB.User.User[steam_id: binary_to_integer(api_data["steamid"]), name: api_data["personaname"], avatar_url: api_data["avatar"]]
    Comptool.DB.User.save(user)

    redirect conn, to: "/"
  end
end