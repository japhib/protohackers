defmodule P0SmokeTestTest do
  use ExUnit.Case
  doctest P0SmokeTest

  test "greets the world" do
    assert P0SmokeTest.hello() == :world
  end
end
