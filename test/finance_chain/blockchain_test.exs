defmodule BlockChain.BlockchainTest do
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
      data = %Wallet{
        origin: 0,
        destination: 1,
        amount: 1,
      }
      blockchain = BlockChain.add_block(blockchain, data)
      [_, block] = blockchain.chain
      assert block.data == data
    end

    test "validate a chain", %{blockchain: blockchain} do
      # add block into blockchain
      blockchain = BlockChain.add_block(blockchain, %Wallet{
        origin: 0,
        destination: 0,
        amount: 100,
      })
      # assert if blockchain is valid
      assert BlockChain.valid_chain?(blockchain)
    end


    test "when we temper hash in existing chain", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> BlockChain.add_block(%Wallet{
          origin: 0,
          destination: 0,
          amount: 100,
        })
        |> BlockChain.add_block(%Wallet{
          origin: 0,
          destination: 0,
          amount: 100,
        })

        |> BlockChain.add_block(%Wallet{
          origin: 0,
          destination: 0,
          amount: 100,
        })

      # validate if blockchain is valid
      assert BlockChain.valid_chain?(blockchain)
      # temper the blockchain, assume at location 2
      index = 2
      tempered_block = put_in(Enum.at(blockchain.chain, index).hash, %Wallet{
        origin: 0,
        destination: 0,
        amount: 100,
      })

      blockchain = %BlockChain{chain: List.replace_at(blockchain.chain, index, tempered_block)}

      # should invalidate the blockchain
      refute BlockChain.valid_chain?(blockchain)
    end

    test "count total amoun for origin and destination",%{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> BlockChain.add_block(%Wallet{
          origin: 1,
          destination: 0,
          amount: 100,
        })
        |> BlockChain.add_block(%Wallet{
          origin: 1,
          destination: 0,
          amount: 100,
        })

        |> BlockChain.add_block(%Wallet{
          origin: 0,
          destination: 1,
          amount: 100,
        })
        |> BlockChain.add_block(%Wallet{
          origin: 0,
          destination: 1,
          amount: 100,
        })

      assert BlockChain.total_amount(blockchain, 0) == 200 && BlockChain.total_amount(blockchain, 1) == 200
    end

  end



  defp initialize_blockchain(context), do: Map.put(context, :blockchain, BlockChain.new())
end
