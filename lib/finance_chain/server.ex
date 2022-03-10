defmodule FinanceChain.BlockChain.Server do
  use GenServer
  alias FinanceChain.BlockChain
  # alias FinanceChain.BlockChain.Wallet

  def init(blockchain) do
    {:ok, blockchain}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, FinanceChain.BlockChain.new(), opts)
  end

  def send_money(pid, value) do
    GenServer.call(pid, {:add, value})
  end

  @spec get_blockchain(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def get_blockchain(pid) do
    GenServer.call(pid, {:get})
  end

  def handle_call({:add, value}, _from, state) do
    state = BlockChain.add_block(state, value)
    {:reply, "#sended value", state}
  end

  def handle_call({:get}, _from, state) do
    {:reply, state ,state}
  end

end
