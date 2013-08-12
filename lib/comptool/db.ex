defmodule Comptool.DB do
  use GenServer.Behaviour

  def start_link(nil) do
    :gen_server.start_link({ :local, __MODULE__ }, __MODULE__, nil, [])
  end

  def init(nil) do
    settings = Comptool.Settings.get(:database)
    case handle_call(:get_connection, nil, settings) do
      { :reply, _conn, ^settings } -> { :ok, settings }
      { :error, reason } -> { :stop, { :no_connection, reason } }
    end
  end

  def get_connection() do
    :gen_server.call(__MODULE__, :get_connection)
  end

  # Returns { :ok, result or count }
  def bound_simple_query(conn, sql, params // []) do
    { :ok, statement } = :pgsql.parse(conn, sql)
    :ok = :pgsql.bind(conn, statement, params)
    :pgsql.execute(conn, statement)
  end

  # `table`, `where_key`, and keys of `fields` must be atoms and not
  # be tainted by user content!
  # `where_key` and `where_value` should not be in fields. They will
  # be added automatically if necessary.
  def insert_or_update!(conn, table, where_key, where_value, fields) when is_atom(table) and is_list(fields) and is_atom(where_key) do
    { :ok, _ } = bound_simple_query(conn, "BEGIN")
    case bound_simple_query(conn, "SELECT * FROM #{table} WHERE #{where_key} = $1 LIMIT 1", [where_value]) do
      { :ok, [_row] } -> # update
        setters = Enum.map(
          fields |> Keyword.keys |> Enum.with_index,
          fn {k,i} -> "#{k} = $#{i+1}" end
        ) |> Enum.join(", ")
        { :ok, 1 } = bound_simple_query(conn, "UPDATE #{table} SET #{setters} WHERE #{where_key} = $#{Enum.count(fields) + 1}", Keyword.values(fields) ++ [where_value])
    { :ok, [] } -> # insert
        keys = [ where_key | (fields |> Keyword.keys) ] |> Enum.join(", ")
        values = [ where_value | (fields |> Keyword.values) ]
        placeholders = "$" <> (Stream.iterate(1, &1+1) |> Enum.take(Enum.count(values)) |> Enum.join(", $"))
        { :ok, 1 } = bound_simple_query(conn, "INSERT INTO #{table} (#{keys}) VALUES (#{placeholders})", values)
    end
    { :ok, _ } = bound_simple_query(conn, "COMMIT")
    :ok
  end

  def handle_call(:get_connection, _from, settings) do
    { :ok, conn } = :pgsql.connect(
      binary_to_list(settings[:host]),
      binary_to_list(settings[:user]),
      binary_to_list(settings[:password]),
      port: settings[:port],
      database: 'comptool'
    )
    { :reply, conn, settings }
  end
end
