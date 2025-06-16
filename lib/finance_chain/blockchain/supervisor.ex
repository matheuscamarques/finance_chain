defmodule FinanceChain.BlockChain.Supervisor do
  @moduledoc """
  This module defines a supervisor for the `FinanceChain.BlockChain.Server`.
  It ensures the `BlockChain.Server` is always running.
  """
  use Supervisor

  @doc """
  Starts the supervisor link.
  """
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  @doc """
  Initializes the supervisor with its children.
  Currently supervises a single `FinanceChain.BlockChain.Server` instance.
  """
  def init(:ok) do
    children = [
      {FinanceChain.BlockChain.Server, name: FinanceChain.BlockChain.Server}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
