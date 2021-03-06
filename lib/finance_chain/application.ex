defmodule FinanceChain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      FinanceChainWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FinanceChain.PubSub},
      # Start the Endpoint (http/https)
      FinanceChainWeb.Endpoint,
      # Start a worker by calling: FinanceChain.Worker.start_link(arg)
      # {FinanceChain.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinanceChain.Supervisor]
    Supervisor.start_link(children, opts)

    FinanceChain.BlockChain.Supervisor.start_link(name: FinanceChain.BlockChain.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinanceChainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
