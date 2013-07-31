defmodule CastersRouter do
  use Dynamo.Router

  prepare do
    conn = conn.assign :section, "casters"
    conn.assign :top_links, ["options"]
  end

  get "" do
    render conn, "casters.html"
  end

  get "options" do
    render conn, "casters/options.html"
  end
end
