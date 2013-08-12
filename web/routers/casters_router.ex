defmodule CastersRouter do
  use Dynamo.Router

  prepare do
    conn = conn.assign :section, "casters"

    if conn.assigns[:logged_in] do
      user = Comptool.DB.User.get_by_steam_id! conn.assigns[:steam_info][:steam_id]
      if ! user.caster_access do
        case { user.caster_access_requested, conn.path, conn.method } do
          { false, "/casters/request-access", "POST" } ->
            with_flag = user.update(caster_access_requested: true)
            subject = 'Casting tool access request'
            body = '''
Name:     #{ user.name }
Steam ID: #{ user.steam_id }
Profile:  https://steamcommunity.com/profiles/#{ user.steam_id }
'''
            :sendmail.send('bluejeansummer@gmail.com', 'bluejeans@comptool.tf', subject, body)
            Comptool.DB.User.save(with_flag)
            redirect! conn, to: "/casters/access-requested"
          { true, _, _ } ->
            halt! render(conn, "casters/access_requested.html")
          _ ->
            halt! render(conn, "casters/request_access.html")
        end
      else
        conn = conn.assign :top_links, ["options"]
        conn.assign :user, user
      end
    else
      redirect! conn, "/login"
    end
  end

  get "" do
    render conn, "casters.html"
  end

  get "options" do
    render conn, "casters/options.html"
  end
end
