defmodule FinanceChain.BlockChain.AccountServer do
  @moduledoc """
  A GenServer that manages the blockchain for a single financial account.
  Each unique account in the system will have its own instance of this process,
  maintaining its independent chain of transactions.
  """
  use GenServer
  alias FinanceChain.BlockChain.{Chain, Wallet}

  # =================================================================
  #  Public Process API
  # =================================================================

  @spec start_link(pos_integer()) :: GenServer.on_start()
  @doc """
  Starts an `AccountServer` linked process for a specific `account_id`.
  The process is registered in `FinanceChain.Registry` using a `via_tuple`
  for easy lookup by its `account_id`.
  """
  def start_link(account_id) do
    GenServer.start_link(__MODULE__, account_id, name: via_tuple(account_id))
  end

  @spec get_balance(pid | atom) :: {:ok, number()}
  @doc """
  Retrieves the current balance of the account managed by the specified `pid`.
  This is a synchronous GenServer call.
  """
  def get_balance(pid) do
    GenServer.call(pid, :get_balance, :infinity)
  end

  @spec add_transaction(pid | atom, Wallet.t()) :: :ok
  @doc """
  Adds a new transaction (`wallet`) to the account's blockchain managed by the specified `pid`.
  This is an asynchronous GenServer cast.
  """
  def add_transaction(pid, %Wallet{} = wallet) do
    GenServer.cast(pid, {:add_transaction, wallet})
  end

  # =================================================================
  #  GenServer Callbacks (WITH CORRECTIONS)
  # =================================================================

  @impl true
  @doc """
  Initializes the `AccountServer` process.
  It sets up the initial blockchain for the `account_id` with a genesis transaction
  related to that specific account.
  The state is now a tuple `{account_id, chain}`.
  """
  def init(account_id) do
    # Create a genesis wallet for this specific account.
    genesis_wallet = %Wallet{
      origin: account_id,
      destination: account_id,
      amount: 0,
      signature: "GENESIS"
    }

    # Initialize a new chain and add the account's genesis block to it.
    chain = Chain.new() |> Chain.add_block(genesis_wallet)

   initial_balance = Chain.total_amount(chain, account_id)
    {:ok, {account_id, chain, initial_balance}}
  end

  @impl true
  @doc """
  Handles synchronous `:get_balance` calls.
  It calculates the total balance from the account's `chain` and returns it.
  """
  def handle_call(:get_balance, _from, {account_id, chain, balance}) do
    {:reply, {:ok, balance}, {account_id, chain, balance}}
  end

  @impl true
  @doc """
  Handles asynchronous `{:add_transaction, wallet}` casts.
  It adds the new `wallet` transaction to the account's `chain` and updates the state.
  """
  # CHANGE 5: The `handle_cast` also needs to be updated for the new state format.
  def handle_cast({:add_transaction, wallet}, {account_id, chain, _balance}) do
    new_chain = Chain.add_block(chain, wallet)
    new_balance = Chain.total_amount(new_chain, account_id)
    {:noreply, {account_id, new_chain, new_balance}}
  end

  @doc """
  Helper function to create a `via_tuple` for registering the `AccountServer`
  process in the `FinanceChain.Registry` using the `account_id` as the key.
  """
  def via_tuple(account_id) do
    {:via, Registry, {FinanceChain.Registry, account_id}}
  end
end
