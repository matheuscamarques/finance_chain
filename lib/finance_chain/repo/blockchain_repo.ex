defmodule FinanceChain.Repo.BlockChain do
      alias FinanceChain.Services.Utils
      alias FinanceChain.BlockChain.Wallet
      alias FinanceChain.BlockChain.Server

      @spec reset :: :ok
      def reset do
        Server |> Server.reset_blockchain()
        :ok
      end

      @spec get_blockchain :: FinanceChain.BlockChain.t()
      def get_blockchain do
        Server |> Server.get_blockchain()
      end

     @spec get_balance(Int.t()) :: Int.t()
     def get_balance(id) do
       get_blockchain() |> Utils.total_amount(id)
     end


     @spec add_block(Wallet.t()) :: :ok
     def add_block(%Wallet{} = wallet) do
       Server |> Server.send_event(wallet)
       :ok
     end

end
