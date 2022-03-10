defmodule FinanceChain.BlockChain do
  @moduledoc """
  This module contains the blockchain related functions
  """
  alias __MODULE__
  alias FinanceChain.BlockChain.Block

  defstruct ~w(chain)a

  @type t :: %BlockChain{
          chain: [Block.t({})]
        }

  @spec new :: BlockChain.t()
  def new() do
    %__MODULE__{}
    |> add_genesis()
  end

  defp add_genesis(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end
  @spec add_block(BlockChain.t(), any) :: BlockChain.t()
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    {last_block, _} = List.pop_at(chain, -1)

    %{blockchain | chain: chain ++ [Block.mine_block(last_block, data)]}
  end

  @spec valid_chain?(BlockChain.t()) :: boolean()
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

  def total_amount_for_origin([],_) do
    0
  end

  def total_amount_for_origin([a|b],originID) when a.data.origin == originID do
      a.data.amount + total_amount_for_origin(b,originID)
  end

  def total_amount_for_origin([a|b],originID) when a.data.origin != originID do
      total_amount_for_origin(b,originID)
  end

  def total_amount_for_destination([],_) do
    0
  end

  def total_amount_for_destination([a|b],destinationID) when a.data.destination == destinationID do
      a.data.amount + total_amount_for_destination(b,destinationID)
  end

  def total_amount_for_destination([a|b],destinationID) when a.data.destination != destinationID do
      total_amount_for_destination(b,destinationID)
  end

  def total_amount_for_origin_and_destination([],_) do
    0
  end

  def total_amount( %__MODULE__{chain: chain}, originID) do
     total_amount_for_destination(chain, originID) - total_amount_for_origin(chain, originID)
  end


end
