defmodule RaindropTest do
  use ExUnit.Case
  doctest Raindrop

  test "greets the world" do
    assert Raindrop.hello() == :world
  end
end
