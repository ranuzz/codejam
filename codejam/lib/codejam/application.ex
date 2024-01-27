defmodule Codejam.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CodejamWeb.Telemetry,
      Codejam.Repo,
      {DNSCluster, query: Application.get_env(:codejam, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Codejam.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Codejam.Finch},
      # Start a worker by calling: Codejam.Worker.start_link(arg)
      # {Codejam.Worker, arg},
      # Start to serve requests, typically the last entry
      CodejamWeb.Presence,
      CodejamWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Codejam.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CodejamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
