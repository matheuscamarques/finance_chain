defmodule FinanceChain.Services.BlockChain do
  alias FinanceChain.Repo.BlockChain
  alias FinanceChain.BlockChain.Wallet
  alias FinanceChain.Services.Utils

  def reset do
    BlockChain.reset()
  end

  def id_exist?(id) do
    blockchain = BlockChain.get_blockchain()

    if(Utils.search(blockchain, id) == 0) do
      false
    else
      true
    end
  end

  def get_balance_for_non_existing_account(id) do
    BlockChain.get_balance(id)
  end

  def get_balance_for_existing_account(id) do
    BlockChain.get_balance(id)
  end

  def create_account_with_initial_balance(%Wallet{} = wallet)
      when wallet.origin == 0 and wallet.destination != 0 and wallet.signature == "deposit" do
    BlockChain.add_block(wallet)
    amount = BlockChain.get_balance(wallet.destination)
    {:ok, %{destination: %{balance: amount, id: wallet.destination,}}}
  end

  def deposit_into_existing_account(%Wallet{} = wallet)
      when wallet.origin == 0 and wallet.destination != 0 and wallet.signature == "deposit" do
    BlockChain.add_block(wallet)
    amount = BlockChain.get_balance(wallet.destination)
    {:ok, %{destination: %{balance: amount,id: wallet.destination}}}
  end

  def deposit(%Wallet{} = wallet)
      when wallet.origin == 0 and wallet.destination != 0 and wallet.signature == "deposit" do
    BlockChain.add_block(wallet)
    amount = BlockChain.get_balance(wallet.destination)
    {:ok, %{destination: %{ balance: amount , id: wallet.destination,}}}
  end



  def withdraw_from_non_existing_account(%Wallet{} = wallet)
      when wallet.signature == "withdraw" do
    blockchain = BlockChain.get_blockchain()
    id = Utils.search(blockchain, wallet.origin)
    withdraw(id, wallet)
  end

  def withdraw_from_existing_account(%Wallet{} = wallet) when wallet.signature == "withdraw" do
    blockchain = BlockChain.get_blockchain()
    id = Utils.search(blockchain, wallet.origin)
    withdraw(id, wallet)
  end

  def withdraw(%Wallet{} = wallet) when wallet.signature == "withdraw" do
    blockchain = BlockChain.get_blockchain()
    id = Utils.search(blockchain, wallet.origin)
    withdraw(id, wallet)
  end

  defp withdraw(0, _), do: {:err, 0}

  defp withdraw(id, wallet) when id > 0 do
    BlockChain.add_block(wallet)
    amount = BlockChain.get_balance(wallet.origin)
    {:ok, %{origin: %{balance: amount , id: wallet.origin}}}
  end

  def transfer_from_existing_account(%Wallet{} = wallet) when wallet.signature == "transfer" do
    blockchain = BlockChain.get_blockchain()
    id = Utils.search(blockchain, wallet.origin)
    transfer(id, wallet)
  end

  def transfer_from_non_existing_account(%Wallet{} = wallet)
      when wallet.signature == "transfer" do
    blockchain = BlockChain.get_blockchain()
    id = Utils.search(blockchain, wallet.origin)
    transfer(id, wallet)
  end

  def transfer(%Wallet{} = wallet)
      when wallet.signature == "transfer" do
    blockchain = BlockChain.get_blockchain()
    id = Utils.search(blockchain, wallet.origin)
    transfer(id, wallet)
  end

  defp transfer(0, _), do: {:err, 0}

  defp transfer(id, wallet) when id > 0 do
    BlockChain.add_block(wallet)
    origin_amount = BlockChain.get_balance(wallet.origin)
    destination_amount = BlockChain.get_balance(wallet.destination)

    {:ok,
     %{
       destination: %{ balance: destination_amount, id: wallet.destination},
       origin: %{ balance: origin_amount , id: wallet.origin}
     }}
  end
end
