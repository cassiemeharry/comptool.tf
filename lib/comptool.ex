defmodule CompTool do
  use Application.Behaviour

  defp static_page(path, file // nil) do
    if file == nil do
      file = (path <> ".html") |> String.lstrip(?/) |> String.replace("/", "-")
    end
    {path, :cowboy_static, [
      directory: {:priv_dir, CompTool, ["pages"]},
      file: file,
      mimetypes: {fn (x, y) -> :mimetypes.path_to_mimes(x,y) end, :default},
    ]}
  end

  defp init_db() do
    {:ok, pid} = :sqlite3.open(:comptool_data)
    :sqlite3.sql_exec_script(
      pid, """
CREATE TABLE IF NOT EXISTS sessions (
    sid TEXT NOT NULL UNIQUE ON CONFLICT IGNORE,
    data BLOB
);
"""
    )
  end

  defp get_settings() do
    priv_dir = Path.join(
      Path.dirname(__FILE__) |> Path.dirname,
      "priv"
    )
    conf_file = Path.join([priv_dir, "settings.yml"])
    {:ok, [config]} = :yaml.load_file(binary_to_list(conf_file), [:implicit_atoms])
    config
  end

  def start(_type, _args) do
    init_db()
    config = get_settings()

    api = [
      {"/api/user", CompTool.API.User, config},
    ]

    static_pages = [
      static_page("/", "index.html"),
      static_page("/about"),
      {"/[...]", :cowboy_static, [
        directory: {:priv_dir, CompTool, ["static"]},
        mimetypes: {fn (x, y) -> :mimetypes.path_to_mimes(x,y) end, :default}
      ]},
    ]

    routes = [
      {:_, [
        {"/login", CompTool.LoginHandler, config},
        {"/login-return", CompTool.LoginHandler, config},
      ] ++ api ++ static_pages}
    ]
    dispatch = :cowboy_router.compile(routes)
    {:ok, _} = :cowboy.start_http(
      :http, 100,
      [port: config |> Keyword.get!(:http) |> Keyword.get(:port)],
      [
        env: [
          dispatch: dispatch,
          session_opts: { :cowboy_cookie_session, {"sid", "my secret", 60 * 60 * 24, "/"}}
        ],
        middlewares: [
          :cowboy_router,
          CompTool.Middleware.RequestLogger,
          CompTool.Middleware.Session,
          :cowboy_handler,
        ]
      ]
    )
    CompTool.Supervisor.start_link
  end
end
