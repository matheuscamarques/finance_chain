defmodule FinanceChainWeb.EventController do
  use FinanceChainWeb, :controller
  alias FinanceChain.Services.BlockChain
  alias FinanceChain.BlockChain.Wallet
  def reset(conn,_) do
    BlockChain.reset()
    conn |> put_status(200) |> text("OK")
  end
  # GET /balance?account_id=1234
  def balance(conn, %{"account_id" => account_id}) do
    if BlockChain.id_exist?(account_id) == false do
      res = BlockChain.get_balance_for_non_existing_account(account_id)
      conn
      |> put_status(404)
      |> json(res)
    else
      res = BlockChain.get_balance_for_existing_account(account_id)
      conn
      |> put_status(200)
      |> json(res)
    end
  end


  def post_event(conn, %{
    "type" => "deposit",
    "destination" => destination,
    "amount" => amount,
  }) do

    wallet = %Wallet{
        origin: 0,
        destination: destination,
        amount: amount,
        signature: "deposit"
    }

    {:ok,deposit} = BlockChain.deposit(wallet)
    conn
     |> put_status(201)
     |> json(deposit)
  end

  def post_event(conn, %{
    "type" => "withdraw",
    "origin" => origin,
    "amount" => amount,
  }) do

    wallet = %Wallet{
        origin: origin,
        destination: 0,
        amount: amount,
        signature: "withdraw"
    }

    {atom,withdraw} = BlockChain.withdraw(wallet)

    if( atom == :ok ) do
      conn
       |> put_status(201)
       |> json(withdraw)
    else
      conn
       |> put_status(404)
       |> json(withdraw)
    end
  end


  def post_event(conn, %{
    "type" => "transfer",
    "origin" => origin,
    "amount" => amount,
    "destination" => destination,
  }) do

    wallet = %Wallet{
        origin: origin,
        destination: destination,
        amount: amount,
        signature: "transfer"
    }

    {atom,transfer} = BlockChain.transfer(wallet)

    if( atom == :ok ) do
      conn
       |> put_status(201)
       |> json(transfer)
    else
      conn
       |> put_status(404)
       |> json(transfer)
    end
  end


end
