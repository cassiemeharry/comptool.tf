defmodule Comptool.DB.User do
  defrecord User,
    steam_id: nil,
    name: nil,
    avatar_url: nil,
    caster_access_requested: false,
    caster_access: false

  def get_by_steam_id!(steam_id) do
    steam_id = binary_to_integer(steam_id)
    conn = Comptool.DB.get_connection()
    case Comptool.DB.bound_simple_query(
      conn,
      "SELECT players.steam_id, players.name, users.avatar_url, users.caster_access_requested, users.caster_access FROM users INNER JOIN players ON users.steam_id = players.steam_id WHERE users.steam_id = $1 LIMIT 1",
      [steam_id]
    ) do
      { :ok, [] } -> nil
      { :ok, [{steam_id, name, avatar_url, caster_access_requested, caster_access}] } ->
        User[
        steam_id: steam_id,
        name: name,
        avatar_url: avatar_url,
        caster_access_requested: caster_access_requested,
        caster_access: caster_access
      ]
    end
  end

  def save(user) when is_record(user, User) do
    conn = Comptool.DB.get_connection()

    Comptool.DB.insert_or_update!(
      conn, :players, :steam_id, user.steam_id,
      name: user.name
    )
    Comptool.DB.insert_or_update!(
      conn, :users, :steam_id, user.steam_id,
      avatar_url: user.avatar_url || "",
      caster_access_requested: user.caster_access_requested || false,
      caster_access: user.caster_access || false
    )

    :ok
  end
end
