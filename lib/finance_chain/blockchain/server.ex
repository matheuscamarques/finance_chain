defmodule FinanceChain.BlockChain.Server do
  use GenServer
  # <<< MUDANÇA IMPORTANTE
  alias FinanceChain.BlockChain.Chain

  def init(_opts) do
    # Agora chama a função `new` do módulo Chain
    {:ok, Chain.new()}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def send_event(pid, value) do
    # Vamos usar uma tupla para o handle_call ficar mais específico
    GenServer.call(pid, {:add_block, value})
  end

  def get_blockchain(pid) do
    GenServer.call(pid, :get_state)
  end

  def reset_blockchain(pid) do
    GenServer.call(pid, :reset)
  end

  # handle_call com a mudança
  def handle_call({:add_block, value}, _from, state) do
    # Chama a função `add_block` do módulo Chain
    new_state = Chain.add_block(state, value)
    {:reply, :ok, new_state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:reset, _from, _state) do
    # Reinicia o estado usando o módulo Chain
    new_state = Chain.new()
    {:reply, :ok, new_state}
  end
end
