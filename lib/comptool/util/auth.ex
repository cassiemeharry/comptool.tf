defmodule CompTool.Util.Auth do
  def ensure_id(req, steam_override // nil) do
    {sid, req} = :cowboy_req.cookie("sid", req, nil)
    session = CompTool.Util.Session.get(sid)

    if ! Keyword.keyword?(session) do
      session = Keyword.new()
    end

    ids = Keyword.get(session, :ids, [])
    local = Keyword.get(ids, :local)
    steam = Keyword.get(ids, :steam)

    if steam == nil and steam_override != nil do
      steam = steam_override
      ids = Keyword.put(ids, :steam, steam)
    end

    if local == nil do
      local = :random.uniform(1000000)
      ids = Keyword.put(ids, :local, local)
    end

    session = Keyword.merge(session, [ids: ids])
    CompTool.Util.Session.set!(sid, session)

    {ids, req}
  end
end