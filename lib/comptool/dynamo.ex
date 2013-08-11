defmodule Comptool.Dynamo do
  use Dynamo

  config :dynamo,
    # The environment this Dynamo runs on
    env: Mix.env,

    # The OTP application associated to this Dynamo
    otp_app: :comptool,

    # The endpoint to dispatch requests to
    endpoint: ApplicationRouter,

    # The route from where static assets are served
    # You can turn off static assets by setting it to false
    static_route: "/static"

  # Uncomment the lines below to enable the cookie session store
  config :dynamo,
    session_store: Session.CookieStore,
    session_options:
      [ key: "_comptool_session",
        secret: "c8K2gWdGs0Yj7X5mFV4zf5HyOOKbBcYSNdfeGD00fz/htiN5WCV+NdNoLg5MXriu"]

  config :server, # painful hack to get around this being defined at compile time
    port: (
      Comptool.Settings.init(nil)
      |> tuple_to_list
      |> Enum.at(1)
      |> Keyword.get(Mix.env)
      |> Keyword.get(:web)
      |> Keyword.get(:web_tcp_port)
    )

  # Default functionality available in templates
  templates do
    use Dynamo.Helpers
  end
end
