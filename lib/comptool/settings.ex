# This is basically a read-only global variable to hold the settings file
defmodule Comptool.Settings do
  use GenServer.Behaviour

  def start_link(settings) do
    :gen_server.start_link({ :local, __MODULE__ }, __MODULE__, settings, [])
  end

  def get(keys) do
    :gen_server.call(__MODULE__, keys)
  end

  def handle_call(keys, _from, settings) when is_list(keys) do
    result = Enum.reduce([Mix.env | keys], settings, Keyword.get(&2, &1))

    { :reply, result, settings }
  end

  def handle_call(key, from, settings) do
    handle_call([key], from, settings)
  end
end
