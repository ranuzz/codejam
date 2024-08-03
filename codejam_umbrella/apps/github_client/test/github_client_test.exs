defmodule GithubClientTest do
  use ExUnit.Case
  doctest GithubClient

  test "greets the world" do
    assert GithubClient.hello() == :world
  end
end
