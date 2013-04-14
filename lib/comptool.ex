defmodule CompTool do
  use Application.Behaviour

  def start(_type, _args) do
    priv_dir = Path.join(
      Path.dirname(__FILE__) |> Path.dirname,
      "priv"
    )
    conf_file = Path.join([priv_dir, "settings.yml"])
    {:ok, [config]} = :yaml.load_file(binary_to_list(conf_file), [:implicit_atoms])
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/login", CompTool.LoginHandler, config},
        {"/login-return", CompTool.LoginHandler, config},
        {"/", :cowboy_static, [
          directory: {:priv_dir, CompTool, ["static"]},
          file: "index.html",
          mimetypes: {fn (x, y) -> :mimetypes.path_to_mimes(x,y) end, :default}
        ]},
        {"/[...]", :cowboy_static, [
          directory: {:priv_dir, CompTool, ["static"]},
          mimetypes: {fn (x, y) -> :mimetypes.path_to_mimes(x,y) end, :default}
        ]}
      ]}
    ])
    {:ok, _} = :cowboy.start_http(
      :http, 100,
      [port: 5000],
      [
        env: [
          dispatch: dispatch,
          session_opts: { :cowboy_cookie_session, {"sid", "my secret", 1000, "/"}}
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
