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
end
