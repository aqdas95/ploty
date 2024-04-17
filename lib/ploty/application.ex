defmodule Ploty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PlotyWeb.Telemetry,
      Ploty.Repo,
      {DNSCluster, query: Application.get_env(:ploty, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ploty.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ploty.Finch},
      # Start a worker by calling: Ploty.Worker.start_link(arg)
      # {Ploty.Worker, arg},
      # Start to serve requests, typically the last entry
      PlotyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ploty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PlotyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
