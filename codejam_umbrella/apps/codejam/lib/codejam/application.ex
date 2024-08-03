defmodule Codejam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Codejam.Repo,
      {DNSCluster, query: Application.get_env(:codejam, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Codejam.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Codejam.Finch}
      # Start a worker by calling: Codejam.Worker.start_link(arg)
      # {Codejam.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Codejam.Supervisor)
  end
end
