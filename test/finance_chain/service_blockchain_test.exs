defmodule FinanceChain.Services.BlockChainTest do
  use ExUnit.Case

  alias FinanceChain.Services.BlockChain
  alias FinanceChain.BlockChain.Wallet

  describe "Service Blockchain" do
    setup [:initialize_blockchain]

    test "Get balance for non-existing account" do
      assert 0 == BlockChain.get_balance_for_non_existing_account(1234)
    end

    test "Create account with initial balance" do
      v = {:ok, %{destination: %{balance: 10, id: 100}}}

      assert v ==
               BlockChain.create_account_with_initial_balance(%Wallet{
                 signature: "deposit",
                 destination: 100,
                 origin: 0,
                 amount: 10
               })
    end

    test "Deposit into existing account" do
      BlockChain.create_account_with_initial_balance(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      v = {:ok, %{destination: %{balance: 20, id: 100}}}

      assert v ==
               BlockChain.deposit_into_existing_account(%Wallet{
                 signature: "deposit",
                 destination: 100,
                 origin: 0,
                 amount: 10
               })
    end

    test "Get balance for existing account" do
      BlockChain.create_account_with_initial_balance(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.deposit_into_existing_account(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      assert 20 == BlockChain.get_balance_for_existing_account(100)
    end

    test "Withdraw from non-existing account" do
      BlockChain.create_account_with_initial_balance(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.deposit_into_existing_account(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      assert {:err,0 } ==
               BlockChain.withdraw_from_non_existing_account(%Wallet{
                 signature: "withdraw",
                 destination: 0,
                 origin: 200,
                 amount: 10
               })
    end

    test "Withdraw from existing account" do
      BlockChain.create_account_with_initial_balance(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.deposit_into_existing_account(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      v = {:ok, %{origin: %{balance: 15, id: 100}}}

      assert v ==
               BlockChain.withdraw_from_existing_account(%Wallet{
                 signature: "withdraw",
                 destination: 0,
                 origin: 100,
                 amount: 5
               })
    end

    test "Transfer from existing account" do
      BlockChain.create_account_with_initial_balance(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.deposit_into_existing_account(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.withdraw_from_existing_account(%Wallet{
        signature: "withdraw",
        destination: 0,
        origin: 100,
        amount: 5
      })

      assert {:ok, %{destination: %{balance: 5, id: 300}, origin: %{balance: 10, id: 100}}} ==
               BlockChain.transfer_from_existing_account(%Wallet{
                 signature: "transfer",
                 destination: 300,
                 origin: 100,
                 amount: 5
               })
    end

    test "Transfer from non-existing account" do
      BlockChain.create_account_with_initial_balance(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.deposit_into_existing_account(%Wallet{
        signature: "deposit",
        destination: 100,
        origin: 0,
        amount: 10
      })

      BlockChain.withdraw_from_existing_account(%Wallet{
        signature: "withdraw",
        destination: 0,
        origin: 100,
        amount: 5
      })

      assert {:err,0} == BlockChain.transfer_from_non_existing_account(%Wallet{
        signature: "transfer",
        destination: 300,
        origin: 200,
        amount: 5
      })
    end

  end

  defp initialize_blockchain(context), do: Map.put(context, :blockchain, BlockChain.reset())
end
