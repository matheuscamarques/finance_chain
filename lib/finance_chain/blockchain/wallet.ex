defmodule FinanceChain.BlockChain.Wallet do
  @moduledoc """
    This module is the single wallet struct in a blockchain
  """
    alias __MODULE__

  @derive {Jason.Encoder, only: [:origin,:destination,:amount]}
  @type t::%Wallet{
          origin:  pos_integer(),
          destination: pos_integer(),
          amount: pos_integer(),
          signature: String.t()
        }

  defstruct ~w(origin destination amount signature)a
 end
