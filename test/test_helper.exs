Dynamo.under_test(Comptool.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule Comptool.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
