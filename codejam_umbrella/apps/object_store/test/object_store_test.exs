defmodule ObjectStoreTest do
  use ExUnit.Case
  doctest ObjectStore

  test "greets the world" do
    assert ObjectStore.hello() == :world
  end
end
