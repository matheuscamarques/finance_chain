defmodule FinanceChain.BlockChain.BlockTest do
  @moduledoc """
  This module contains test related to a block
  """

  use ExUnit.Case
  alias FinanceChain.BlockChain.Block
  alias FinanceChain.BlockChain.Wallet

  describe "block" do
    test "genesis is valid" do
      assert %Block{
               data: %Wallet{
                 origin: 0,
                 destination: 0,
                 amount: 0,
                 signature: "GENISIS"
               },
               hash: "CB2760DE57CA7C9E2BFBEFB878787EE5B0D2F5B8789DD572BFD933396302252E",
               last_hash: "-",
               timestamp: 1_599_909_623_805_627
             } == Block.genesis()
    end

    test "mine block returns new block" do
      %Block{hash: hash} = genesis_block = Block.genesis()

      assert %Block{
               data: "this is mined data",
               last_hash: ^hash
             } = Block.mine_block(genesis_block, "this is mined data")
    end

    test "new give a new block when we pass the parameters" do
      # setup the data
      timestamp = DateTime.utc_now() |> DateTime.to_unix(1_000_000)
      last_hash = "random_hash"
      data = %Wallet{
        origin: 0,
        destination: 0,
        amount: 0,
      }

      assert %Block{timestamp: ^timestamp, hash: _hash, last_hash: ^last_hash, data: ^data} =
               Block.new(timestamp, last_hash, data)
    end
  end
end
