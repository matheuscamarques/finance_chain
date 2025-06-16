defmodule FinanceChain.BlockChain.Chain do
  @moduledoc """
  This module defines the blockchain data structure and low-level functions
  for its manipulation, including adding blocks, calculating balances,
  and validating the chain's integrity.
  """
  alias __MODULE__
  alias FinanceChain.BlockChain.Block

  # Defines the internal structure of the Chain, which is a list of blocks.
  defstruct chain: []

  @type t :: %Chain{
          chain: [Block.t()] # The list of blocks in the blockchain
        }

  @spec new() :: t()
  @doc """
  Creates a new blockchain instance, initialized with a genesis block.
  """
  def new do
    %__MODULE__{}
    |> add_genesis()
  end

  @doc """
  Adds the initial genesis block to a new blockchain.
  This is a private helper function.
  """
  def add_genesis(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end

  @spec add_block(t(), any()) :: t()
  @doc """
  Adds a new block to the blockchain.
  It mines a new block using the hash of the last block and the provided data,
  then appends it to the chain.
  """
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    # Using List.last/1 is a bit cleaner than pop_at
    last_block = List.last(chain)
    new_block = Block.mine_block(last_block, data)
    %{blockchain | chain: chain ++ [new_block]}
  end

  @doc """
  Calculates the total balance for a given `account_id` by
  summing destination amounts and subtracting origin amounts
  from all transactions (wallets) within the blockchain.
  """
  def total_amount(%__MODULE__{chain: blocks}, account_id) do
    Enum.reduce(blocks, 0, fn block, balance_acum ->
      wallet = block.data

      cond do
        # If the account is the destination of the transaction, add the amount
        wallet.destination == account_id ->
          balance_acum + wallet.amount

        # If the account is the origin of the transaction, subtract the amount
        wallet.origin == account_id ->
          balance_acum - wallet.amount

        # Otherwise, the balance does not change for this transaction
        true ->
          balance_acum
      end
    end)
  end

  @doc """
  Returns a `MapSet` containing all unique account IDs that have participated in any transaction
  within the blockchain. The `0` ID (used for system deposits/withdrawals) is excluded.
  """
  def all_accounts(%__MODULE__{chain: blocks}) do
    Enum.reduce(blocks, MapSet.new(), fn block, acc ->
      wallet = block.data
      acc |> MapSet.put(wallet.origin) |> MapSet.put(wallet.destination)
    end)
    # Remove '0' which is used for deposits/withdrawals
    |> MapSet.delete(0)
  end

  @spec valid_chain?(t()) :: boolean()
  @doc """
  Validates the integrity of the blockchain.
  It checks two main conditions for each pair of consecutive blocks:
  1. The `last_hash` of the current block matches the `hash` of the previous block.
  2. The `hash` of the previous block is correctly generated based on its content.
  """
  def valid_chain?(%__MODULE__{chain: chain}) do
    chain
    # Chunk the list into overlapping pairs (e.g., [b1, b2], [b2, b3], ...)
    |> Enum.chunk_every(2, 1, :discard)
    # Check if all pairs satisfy the validation conditions
    |> Enum.all?(fn [prev_block, block] ->
      valid_last_hash?(prev_block, block) && valid_block_hash?(prev_block)
    end)
  end

  # Private functions

  @doc """
  Checks if the `last_hash` of the `_current_block` matches the `hash` of the `_last_block`.
  """
  def valid_last_hash?(
         %Block{hash: hash} = _last_block,
         %Block{last_hash: last_hash} = _current_block
       ) do
    hash == last_hash
  end

  @doc """
  Checks if the `hash` stored in the `current_block` is correctly calculated
  based on its content (timestamp, last_hash, and data).
  """
  def valid_block_hash?(current_block) do
    current_block.hash == Block.block_hash(current_block)
  end
end
