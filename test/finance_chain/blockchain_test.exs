defmodule ExChain.BlockchainTest do
  @moduledoc """
  This module contains test related to a blockchain
  """

  use ExUnit.Case

  alias FinanceChain.BlockChain
  alias FinanceChain.BlockChain.Block
  alias FinanceChain.BlockChain.Wallet

  describe "Blockchain" do
    setup [:initialize_blockchain]

    test "should start with the genesis block", %{blockchain: blockchain} do
      assert %Block{
               data: %Wallet{
                  origin: 0,
                  destination: 0,
                  amount: 0,
               },
               hash: "CB2760DE57CA7C9E2BFBEFB878787EE5B0D2F5B8789DD572BFD933396302252E",
               last_hash: "-",
               timestamp: 1_599_909_623_805_627
             } == hd(blockchain.chain)
    end

    test "adds a new block", %{blockchain: blockchain} do
      data = "foo"
      blockchain = BlockChain.add_block(blockchain, data)
      [_, block] = blockchain.chain
      assert block.data == data
    end
  end

  defp initialize_blockchain(context), do: Map.put(context, :blockchain, BlockChain.new())
end
