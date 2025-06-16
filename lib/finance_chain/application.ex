defmodule FinanceChain.Application do
  @moduledoc """
  The main application module for FinanceChain.
  It defines the supervision tree for all application processes.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Standard Phoenix components
      FinanceChainWeb.Telemetry,
      {Phoenix.PubSub, name: FinanceChain.PubSub},

      # 🏁 Concurrent blockchain components
      # 1. Registry to map account_id -> pid. Ensures unique account IDs.
      {Registry, keys: :unique, name: FinanceChain.Registry},
      # 2. Dynamic supervisor for account processes. It will start and stop AccountServer processes as needed.
      {DynamicSupervisor, strategy: :one_for_one, name: FinanceChain.AccountSupervisor},

      # Start the Endpoint (web server) last, as it depends on other components
      FinanceChainWeb.Endpoint
    ]

    # Define the strategy for the main supervisor and its name
    opts = [strategy: :one_for_one, name: FinanceChain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    # Handles dynamic configuration changes for the Phoenix Endpoint.
    FinanceChainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
