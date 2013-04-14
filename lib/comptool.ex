defmodule CompTool do
  use Application.Behaviour

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [
        {"/[...]", :cowboy_static, [
          directory: {:priv_dir, CompTool, ["static"]},
          file: "index.html",
          mimetypes: {fn (x, y) -> :mimetypes.path_to_mimes(x,y) end, :default}
        ]}
      ]}
    ])
    {:ok, _} = :cowboy.start_http(
      :http, 100,
      [port: 5000],
      [env: [dispatch: dispatch]]
    )
    CompTool.Supervisor.start_link
  end
end
