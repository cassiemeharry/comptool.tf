defmodule CompTool do
  use Application.Behaviour

  defp static_page(path, file // nil) do
    if file == nil do
      file = path <> ".html" |> String.lstrip(?/) |> String.replace("/", "-")
    end
    {path, :cowboy_static, [
      directory: {:priv_dir, CompTool, ["static"]},
      file: file,
      mimetypes: {fn (x, y) -> :mimetypes.path_to_mimes(x,y) end, :default},
    ]}
  end

  def start(_type, _args) do
    priv_dir = Path.join(
      Path.dirname(__FILE__) |> Path.dirname,
      "priv"
    )
    conf_file = Path.join([priv_dir, "settings.yml"])
    {:ok, [config]} = :yaml.load_file(binary_to_list(conf_file), [:implicit_atoms])

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
      [port: 5000],
      [
        env: [
          dispatch: dispatch,
          session_opts: { :cowboy_cookie_session, {"sid", "my secret", 60 * 60 * 24, "/"}}
        ],
        middlewares: [
          :cowboy_router,
          :cowboy_session,
          :cowboy_handler
        ]
      ]
    )
    CompTool.Supervisor.start_link
  end
end
