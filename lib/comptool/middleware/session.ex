defmodule CompTool.Middleware.Session do
  @behaviour :cowboy_middleware

  def execute(req, env) do
    {sid, req} = :cowboy_req.cookie("sid", req, nil)
    if sid == nil do
      sid = :uuid.v4() |> :uuid.to_string |> list_to_binary |> String.replace("-", "")
      CompTool.Util.Session.ensure_in_db(sid)
      req = :cowboy_req.set_resp_cookie(
        "sid", sid,
        [max_age: 60*60*24, path: "/"],
        req,
      )
    end
    {:ok, req, env}
  end
end
