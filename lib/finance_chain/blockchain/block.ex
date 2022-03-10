defmodule FinanceChain.BlockChain.Block do
  @moduledoc """
    This module is the single block struct in a blockchain
  """
  alias __MODULE__
  alias FinanceChain.BlockChain.Wallet

  @type t :: %Block{
          timestamp: pos_integer(),
          last_hash: String.t(),
          hash: String.t(),
          data: Wallet.t()
        }

  defstruct ~w(timestamp last_hash hash data)a

  @spec new(pos_integer(), String.t(), any()) :: Block.t()
  def new(timestamp, last_hash, data) do
    %__MODULE__{}
    |> add_timestamp(timestamp)
    |> add_last_hash(last_hash)
    |> add_data(data)
    |> add_hash()
  end

  @spec get_str(Block.t()) :: String.t()
  def get_str(block = %__MODULE__{}) do
    """
    Block
    timestamp: #{block.timestamp}
    last_hash: #{block.last_hash}
    hash: #{block.hash}
    data: #{block.data}
    """
  end

  @spec genesis() :: Block.t()
  def genesis() do
    __MODULE__.new(1_599_909_623_805_627, "-", %Wallet{
      origin: 0,
      destination: 0,
      amount: 0,
      signature: "GENISIS"
    })
  end

  def mine_block(%__MODULE__{hash: last_hash}, data) do
    __MODULE__.new(get_timestamp(), last_hash, data)
  end

  def block_hash(block = %__MODULE__{}) do
    block.hash
  end

  # private functions
  defp add_timestamp(%__MODULE__{} = block, timestamp), do: %{block | timestamp: timestamp}

  defp add_data(%__MODULE__{} = block, data), do: %{block | data: data}

  defp add_last_hash(%__MODULE__{} = block, last_hash), do: %{block | last_hash: last_hash}

  defp add_hash(%__MODULE__{timestamp: timestamp, last_hash: last_hash, data: data} = block) do
    %{block | hash: hash(timestamp, last_hash, data)}
  end

  defp get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(1_000_000)

  defp hash(timestamp, last_hash, data) do
    data = "#{timestamp}:#{last_hash}:#{Jason.encode!(data)}"
    Base.encode16(:crypto.hash(:sha256, data))
  end

end
