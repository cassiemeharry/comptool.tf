defmodule CompTool.Mixfile do
  use Mix.Project

  def project do
    [ app: :comptool,
      version: "0.0.1",
      deps: deps ]
  end

  def application do
    [ mod: { CompTool, [] },
      applications: [:cowboy, :ibrowse, :sqlite3] ]
  end

  defp deps do
    [
      { :ranch, github: "extend/ranch", tag: "0.8.1" },
      { :cowboy, github: "extend/cowboy" },

      { :mimetypes, github: "spawngrid/mimetypes" },

      { :yamler, github: "superbobry/yamler" },

      { :jsx, github: "talentdeficit/jsx" },

      { :ibrowse, github: "cmullaparthi/ibrowse" },

      { :sqlite3, github: "alexeyr/erlang-sqlite3", tag: "v1.0.1" },
      { :uuid, github: "travis/erlang-uuid" },
    ]
  end
end
