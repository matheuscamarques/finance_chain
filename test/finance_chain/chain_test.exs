defmodule FinanceChain.BlockChain.ChainTest do
  @moduledoc """
  This module contains tests related to the blockchain data structure.
  """

  use ExUnit.Case, async: true

  # O alias agora aponta para o módulo correto da estrutura de dados.
  alias FinanceChain.BlockChain.Chain
  alias FinanceChain.BlockChain.Block
  alias FinanceChain.BlockChain.Wallet

  describe "Blockchain Chain" do
    # O setup agora chama Chain.new()
    setup [:initialize_blockchain]

    test "should start with the genesis block", %{blockchain: blockchain} do
      # Esta asserção permanece a mesma, pois a estrutura do bloco gênese não mudou.
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
             } == hd(blockchain.chain)
    end

    test "adds a new block", %{blockchain: blockchain} do
      data = %Wallet{
        origin: 0,
        destination: 1,
        amount: 1,
        signature: "TEST"
      }

      # Chama a função correta no módulo Chain
      blockchain = Chain.add_block(blockchain, data)
      [_, block] = blockchain.chain
      assert block.data == data
    end

    test "validates a valid chain", %{blockchain: blockchain} do
      blockchain =
        Chain.add_block(blockchain, %Wallet{
          origin: 0,
          destination: 0,
          amount: 100,
          signature: "TEST"
        })

      # Chama a função correta no módulo Chain
      assert Chain.valid_chain?(blockchain)
    end

    #
    # <<< TESTE CORRIGIDO >>>
    #
    test "invalidates a chain with a tampered block hash", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> Chain.add_block(%Wallet{origin: 0, destination: 0, amount: 100, signature: "TEST"})
        |> Chain.add_block(%Wallet{origin: 0, destination: 0, amount: 200, signature: "TEST"})

      # A cadeia deve ser válida antes da adulteração
      assert Chain.valid_chain?(blockchain)

      # Adulterando a cadeia de forma correta
      index_to_tamper = 1
      original_block = Enum.at(blockchain.chain, index_to_tamper)

      # Criamos um bloco adulterado mudando seu hash
      tempered_block = %{original_block | hash: "BOGUS_HASH_12345"}

      # Substituímos o bloco original pelo adulterado
      tempered_chain = List.replace_at(blockchain.chain, index_to_tamper, tempered_block)
      invalid_blockchain = %{blockchain | chain: tempered_chain}

      # Agora, a cadeia deve ser inválida
      refute Chain.valid_chain?(invalid_blockchain)
    end
  end

  defp initialize_blockchain(_context) do
    # Agora chama Chain.new() para criar a instância inicial
    %{blockchain: Chain.new()}
  end
end
