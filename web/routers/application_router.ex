defmodule ApplicationRouter do
  use Dynamo.Router

  prepare do
    conn = conn.fetch([:cookies, :params, :session])
    conn = conn.assign :layout, "main"
    conn.assign :top_links, []
  end

  forward "/api/v1", to: ApiRouter
  forward "/login", to: LoginRouter

  get "/favicon.ico" do
    conn.resp(404, "")
  end

  prepare do
    conn = conn.assign :steam_info, get_session(conn, :steam_info)
    conn = conn.assign :logged_in, (if conn.assigns[:steam_info], do: true, else: false)

    conn
  end

  forward "/casters", to: CastersRouter

  get "/" do
    conn = conn.assign :section, "teams"
    render conn, "index.html"
  end
end
