defmodule Comptool.Mixfile do
  use Mix.Project

  def project do
    [ app: :comptool,
      version: "0.0.1",
      dynamos: [Comptool.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      env: [prod: [compile_path: "ebin"]],
      compile_path: "tmp/#{Mix.env}/comptool/ebin",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:cowboy, :dynamo],
      mod: { Comptool, [] } ]
  end

  defp deps do
    [ { :cowboy, github: "extend/cowboy" },
      { :dynamo, github: "elixir-lang/dynamo" },
      { :json, github: "cblage/elixir-json"  } ]
  end
end
