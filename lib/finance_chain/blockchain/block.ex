defmodule FinanceChain.BlockChain.Block do
  @moduledoc """
  Represents a single block in the FinanceChain blockchain.
  Each block contains a timestamp, a reference to the previous block's hash,
  its own hash, and the transaction data (Wallet).
  """
  alias __MODULE__
  alias FinanceChain.BlockChain.Wallet

  @type t :: %Block{
          timestamp: pos_integer(), # Unix timestamp in microseconds
          last_hash: String.t(),   # The hash of the previous block in the chain
          hash: String.t(),        # The current block's hash
          data: Wallet.t()         # The transaction data (a Wallet struct)
        }

  # Defines the fields of the Block struct. `~w(...)a` is a shorthand for creating an atom list.
  defstruct ~w(timestamp last_hash hash data)a

  @spec new(pos_integer(), String.t(), any()) :: Block.t()
  @doc """
  Creates a new block with the given timestamp, last hash, and data.
  The block's own hash is automatically calculated during creation.
  """
  def new(timestamp, last_hash, data) do
    %__MODULE__{}
    |> add_timestamp(timestamp)
    |> add_last_hash(last_hash)
    |> add_data(data)
    |> add_hash() # Calculate and add the hash based on the block's content
  end

  @spec get_str(Block.t()) :: String.t()
  @doc """
  Returns a formatted string representation of the block's content.
  """
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
  @doc """
  Creates and returns the genesis block (the first block in the blockchain).
  It has a predefined timestamp, a '-' last_hash (as it has no previous block),
  and a dummy wallet transaction for initialization.
  """
  def genesis() do
    __MODULE__.new(1_599_909_623_805_627, "-", %Wallet{
      origin: 0,
      destination: 0,
      amount: 0,
      signature: "GENISIS" # Typo in original: "GENESIS"
    })
  end

  @doc """
  Mines a new block by taking the `hash` of the `last_block` as its `last_hash`
  and including the new transaction `data`. The timestamp is automatically generated.
  """
  def mine_block(%__MODULE__{hash: last_hash}, data) do
    __MODULE__.new(get_timestamp(), last_hash, data)
  end

  @doc """
  Returns the `hash` of the given block.
  """
  def block_hash(block = %__MODULE__{}) do
    block.hash
  end

  # private functions

  @doc """
  Helper function to add a timestamp to a block struct.
  """
  def add_timestamp(%__MODULE__{} = block, timestamp), do: %{block | timestamp: timestamp}

  @doc """
  Helper function to add data (Wallet) to a block struct.
  """
  def add_data(%__MODULE__{} = block, data), do: %{block | data: data}

  @doc """
  Helper function to add the `last_hash` to a block struct.
  """
  def add_last_hash(%__MODULE__{} = block, last_hash), do: %{block | last_hash: last_hash}

  @doc """
  Helper function to calculate and add the `hash` to a block struct.
  The hash is generated based on the block's timestamp, last_hash, and data.
  """
  def add_hash(%__MODULE__{timestamp: timestamp, last_hash: last_hash, data: data} = block) do
    %{block | hash: hash(timestamp, last_hash, data)}
  end

  @doc """
  Generates the current UTC timestamp in microseconds.
  """
  def get_timestamp(), do: DateTime.utc_now() |> DateTime.to_unix(1_000_000)

  @doc """
  Computes the SHA256 hash for a block's content.
  The input data for hashing includes the timestamp, last_hash, and JSON-encoded transaction data.
  The result is Base16 encoded.
  """
  def hash(timestamp, last_hash, data) do
    data = "#{timestamp}:#{last_hash}:#{Jason.encode!(data)}"
    Base.encode16(:crypto.hash(:sha256, data))
  end
end
