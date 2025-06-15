defmodule FinanceChainWeb.EventController do
  use FinanceChainWeb, :controller
  alias FinanceChain.Services.BlockChain
  alias FinanceChain.BlockChain.Wallet
  def reset(conn,_) do
    BlockChain.reset()
    conn
    |> put_status(200)
    |> text("OK")
  end
  # GET /balance?account_id=1234
  def balance(conn, %{"account_id" => account_id}) do
    case BlockChain.get_balance(account_id) do
      {:err, balance} ->
        conn
        |> put_status(404)
        |> json(balance)
      {:ok, balance} ->
        conn
        |> put_status(200)
        |> json(balance)
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

    case BlockChain.deposit(wallet) do
      {:ok,deposit} -> conn
        |> put_status(201)
        |> json(deposit)
    end
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

    case BlockChain.withdraw(wallet) do
      {:ok, withdraw} -> conn
        |> put_status(201)
        |> json(withdraw)
      {:err, error} -> conn
        |> put_status(404)
        |> json(error)
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

    case BlockChain.transfer(wallet) do
      {:ok,transfer} -> conn
        |> put_status(201)
        |> json(transfer)
      {:err, error} -> conn
        |> put_status(404)
        |> json(error)
    end
  end


end
