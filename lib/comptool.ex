defmodule CompTool do
  use Application.Behaviour

  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {:_, [{"/", CompTool.TopPageHandler, []}]}
    ])
    {:ok, _} = :cowboy.start_http(
      :http, 100,
      [port: 5000],
      [env: [dispatch: dispatch]]
    )
    CompTool.Supervisor.start_link
  end
end
