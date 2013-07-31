defmodule ApplicationRouter do
  use Dynamo.Router

  prepare do
    conn = conn.fetch([:cookies, :params])
    conn = conn.assign :layout, "main"
    conn.assign :top_links, []
  end

  forward "/api/v1", to: ApiRouter
  forward "/casters", to: CastersRouter

  get "/favicon.ico" do
    conn.resp(404, "")
  end

  get "/" do
    conn = conn.assign :section, "teams"
    render conn, "index.html"
  end
end
