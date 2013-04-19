defmodule CompTool.Util.Session do
  def get(sid) do
    ensure_in_db(sid)
    [columns: _, rows: [{^sid, session_bin}]] = :sqlite3.sql_exec(
      :comptool_data,
      'SELECT * FROM sessions WHERE sid = ?',
      [sid],
    )
    binary_to_term(session_bin)
  end
  def set!(sid, data) do
    :sqlite3.sql_exec(:comptool_data, 'UPDATE sessions SET data = ? WHERE sid = ?', [:erlang.term_to_binary(data), sid])
    nil
  end
  def ensure_in_db(sid) do
    :sqlite3.sql_exec(
      :comptool_data,
      "INSERT OR IGNORE INTO sessions (sid, data) VALUES (?, ?)",
      [sid, term_to_binary([])],
    )
  end
end
