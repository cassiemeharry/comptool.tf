defmodule CompTool.Mixfile do
  use Mix.Project

  def project do
    [ app: :comptool,
      version: "0.0.1",
      deps: deps ]
  end

  def application do
    [ mod: { CompTool, [] },
      applications: [:cowboy] ]
  end

  defp deps do
    [
      { :ranch, github: "extend/ranch", tag: "0.8.1" },
      { :cowboy, github: "extend/cowboy" },

      { :mimetypes, github: "spawngrid/mimetypes" },

      { :ibrowse, github: "cmullaparthi/ibrowse" },
      { :openid, github: "brendonh/erl_openid" },

      { :base64url, github: "dvv/base64url" },
      { :termit, github: "dvv/termit" },
      { :stable, github: "dvv/stable" }
    ]
  end
end
