defmodule FinanceChain.BlockChain.Server do
  @moduledoc """
  A GenServer that acts as the central coordinator for the overall blockchain.
  It manages the global blockchain state using the `FinanceChain.BlockChain.Chain` module.
  """
  use GenServer
  # <<< IMPORTANT CHANGE
  alias FinanceChain.BlockChain.Chain

  @doc """
  Initializes the GenServer.
  It creates a new, empty blockchain using `Chain.new()` as its initial state.
  """
  @impl true
  def init(_opts) do
    # Now calls the `new` function from the Chain module
    {:ok, Chain.new()}
  end

  @doc """
  Starts the `FinanceChain.BlockChain.Server` linked process.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Sends an event (value) to the blockchain server to be added as a new block.
  This is a synchronous call.
  """
  def send_event(pid, value) do
    # We will use a tuple so handle_call becomes more specific
    GenServer.call(pid, {:add_block, value})
  end

  @doc """
  Retrieves the current state of the blockchain from the server.
  This is a synchronous call.
  """
  def get_blockchain(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Resets the blockchain state managed by this server.
  This is a synchronous call.
  """
  def reset_blockchain(pid) do
    GenServer.call(pid, :reset)
  end

  @impl true
  @doc """
  Handles synchronous calls to the GenServer.
  - `{:add_block, value}`: Adds a new block with the given `value` (wallet transaction) to the blockchain.
  - `:get_state`: Returns the current blockchain state.
  - `:reset`: Resets the blockchain to its initial (genesis) state.
  """
  # handle_call with the change
  def handle_call({:add_block, value}, _from, state) do
    # Calls the `add_block` function from the Chain module
    new_state = Chain.add_block(state, value)
    {:reply, :ok, new_state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, _state) do
    # Resets the state using the Chain module
    new_state = Chain.new()
    {:reply, :ok, new_state}
  end
end
