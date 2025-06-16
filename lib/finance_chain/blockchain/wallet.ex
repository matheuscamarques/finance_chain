defmodule FinanceChain.BlockChain.Wallet do
  @moduledoc """
  Represents a single wallet (transaction) in the FinanceChain blockchain.
  It defines the structure for all financial movements.
  """
  alias __MODULE__

  # Derives a Jason encoder, ensuring only specified fields are included when encoding to JSON.
  @derive {Jason.Encoder, only: [:origin, :destination, :amount]}

  @type t :: %Wallet{
          origin: pos_integer(),        # The ID of the originating account (0 for system deposits)
          destination: pos_integer(),   # The ID of the destination account (0 for system withdrawals)
          amount: pos_integer(),        # The amount of the transaction
          signature: String.t()         # A descriptive signature for the transaction type (e.g., "deposit", "withdraw", "transfer")
        }

  # Defines the fields of the Wallet struct. `~w(...)a` is a shorthand for creating an atom list.
  defstruct ~w(origin destination amount signature)a
end
