defmodule FinanceChain.BlockChain.Chain do
  @moduledoc """
  This module defines the blockchain data structure and low-level functions
  for its manipulation.
  """
  alias __MODULE__
  alias FinanceChain.BlockChain.Block

  defstruct chain: []

  @type t :: %Chain{
          chain: [Block.t()]
        }

  @spec new() :: t()
  def new do
    %__MODULE__{}
    |> add_genesis()
  end

  defp add_genesis(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end

  @spec add_block(t(), any()) :: t()
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    # Usando List.last/1 é um pouco mais limpo que pop_at
    last_block = List.last(chain)
    new_block = Block.mine_block(last_block, data)
    %{blockchain | chain: chain ++ [new_block]}
  end

  @doc """
  Calcula o saldo total para um `account_id`, somando os valores de destino
  e subtraindo os valores de origem de todas as transações na cadeia.
  """
  def total_amount(%__MODULE__{chain: blocks}, account_id) do
    Enum.reduce(blocks, 0, fn block, balance_acum ->
      wallet = block.data

      cond do
        # Se a conta for o destino da transação, soma o valor
        wallet.destination == account_id ->
          balance_acum + wallet.amount

        # Se a conta for a origem da transação, subtrai o valor
        wallet.origin == account_id ->
          balance_acum - wallet.amount

        # Caso contrário, o saldo não muda para esta transação
        true ->
          balance_acum
      end
    end)
  end

  @doc """
  Retorna um MapSet com todos os IDs de contas que já participaram de uma transação.
  """
  def all_accounts(%__MODULE__{chain: blocks}) do
    Enum.reduce(blocks, MapSet.new(), fn block, acc ->
      wallet = block.data
      acc |> MapSet.put(wallet.origin) |> MapSet.put(wallet.destination)
    end)
    # Remove o '0' que é usado para depósitos/saques
    |> MapSet.delete(0)
  end

  @spec valid_chain?(t()) :: boolean()
  def valid_chain?(%__MODULE__{chain: chain}) do
    chain
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [prev_block, block] ->
      valid_last_hash?(prev_block, block) && valid_block_hash?(prev_block)
    end)
  end

  # Private functions

  defp valid_last_hash?(
         %Block{hash: hash} = _last_block,
         %Block{last_hash: last_hash} = _current_block
       ) do
    hash == last_hash
  end

  defp valid_block_hash?(current_block) do
    current_block.hash == Block.block_hash(current_block)
  end
end
