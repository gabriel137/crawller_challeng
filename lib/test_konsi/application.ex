defmodule TestKonsi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TestKonsiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TestKonsi.PubSub},
      # Start Finch
      {Finch, name: TestKonsi.Finch},
      {TestKonsi.Cluster, []},
      {Redix, {"redis://localhost:6379/3", [name: :redix]}},
      # Start the Endpoint (http/https)
      TestKonsiWeb.Endpoint
      # TestKonsi.Crawler.start_link(),
      # Start a worker by calling: TestKonsi.Worker.start_link(arg)
      # {TestKonsi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TestKonsi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TestKonsiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
