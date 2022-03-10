defmodule FinanceChain.Services.BlockChain do
    alias FinanceChain.Repo.BlockChain
    alias FinanceChain.BlockChain.Wallet
    alias FinanceChain.Services.Utils

    def reset do
      BlockChain.reset()
      :ok
    end

   def create_account_with_initial_balance(%Wallet{} = wallet) when wallet.origin == 0 and wallet.destination !=0 and wallet.signature == "deposit" do
     BlockChain.add_block(wallet)
     amount = BlockChain.get_balance(wallet.destination)
     {:ok , %{destination: %{id: wallet.destination, balance: amount}}}
   end

   def get_balance_for_existing_account(id) do
      BlockChain.get_balance(id)
    end


    def withdraw_from_non_existing_account(%Wallet{} = wallet) when wallet.origin != 0 and wallet.signature == "withdraw" do
      blockchain = BlockChain.get_blockchain()
      id = Utils.search(blockchain,wallet.origin)
      withdraw(id,wallet)
    end

    def withdraw_from__existing_account(%Wallet{} = wallet) when wallet.origin != 0 and wallet.signature == "withdraw" do
      blockchain = BlockChain.get_blockchain()
      id = Utils.search(blockchain,wallet.origin)
      withdraw(id,wallet)
    end

    defp withdraw(id,_) when id == 0 do
      0
    end

    defp withdraw(id,wallet) when id != 0 do
      BlockChain.add_block(wallet)
      amount = BlockChain.get_balance(wallet.origin)
      {:ok , %{origin: %{id: wallet.origin, balance: amount}}}
    end
end
