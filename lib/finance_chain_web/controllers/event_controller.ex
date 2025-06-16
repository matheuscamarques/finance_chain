defmodule FinanceChainWeb.EventController do
  use FinanceChainWeb, :controller
  alias FinanceChain.BlockChain
  alias FinanceChain.BlockChain.Wallet

  @doc """
  Resets the entire blockchain state, terminating all account processes.
  This is primarily for development and testing purposes.
  """
  def reset(conn, _) do
    BlockChain.reset()

    conn
    |> put_status(200)
    |> text("OK")
  end

  @doc """
  Retrieves the balance for a given account ID.

  ## Parameters
    - `conn`: The Plug connection.
    - `account_id`: The ID of the account whose balance is requested.

  ## Returns
    - `200 OK` with the balance if the account exists.
    - `404 Not Found` with a balance of `0` if the account does not exist.
  """
  def balance(conn, %{"account_id" => account_id}) do
    case BlockChain.get_balance(account_id) do
      {:error, balance} ->
        conn
        |> put_status(404)
        |> json(balance)

      {:ok, balance} ->
        conn
        |> put_status(200)
        |> json(balance)
    end
  end

  @doc """
  Handles a deposit event, adding funds to a specified destination account.

  ## Parameters
    - `conn`: The Plug connection.
    - `destination`: The ID of the account to deposit into.
    - `amount`: The amount to deposit.

  ## Returns
    - `201 Created` with the updated account balance information on success.
  """
  def post_event(conn, %{
        "type" => "deposit",
        "destination" => destination,
        "amount" => amount
      }) do
    # Create a Wallet struct representing the deposit transaction.
    # An origin of `0` typically indicates a system-generated deposit (e.g., from an ATM).
    wallet = %Wallet{
      origin: 0,
      destination: destination,
      amount: amount,
      signature: "deposit"
    }

    case BlockChain.deposit(wallet) do
      {:ok, deposit} ->
        conn
        |> put_status(201)
        |> json(deposit)
    end
  end

  @doc """
  Handles a withdraw event, deducting funds from a specified origin account.

  ## Parameters
    - `conn`: The Plug connection.
    - `origin`: The ID of the account to withdraw from.
    - `amount`: The amount to withdraw.

  ## Returns
    - `201 Created` with the updated account balance information on success.
    - `404 Not Found` if the origin account does not exist.
    - `422 Unprocessable Entity` if there are insufficient funds in the origin account.
  """
  def post_event(conn, %{"type" => "withdraw", "origin" => origin, "amount" => amount}) do
    # Create a Wallet struct representing the withdrawal transaction.
    # A destination of `0` typically indicates funds leaving the system.
    wallet = %Wallet{origin: origin, destination: 0, amount: amount, signature: "withdraw"}

    case BlockChain.withdraw(wallet) do
      {:ok, withdraw} ->
        conn |> put_status(201) |> json(withdraw)
      {:error, :account_not_found} ->
        conn |> put_status(404) |> json(0)
      {:error, :insufficient_funds} ->
        conn |> put_status(422) |> json(%{error: "insufficient funds"})
    end
  end

  @doc """
  Handles a transfer event, moving funds from an origin account to a destination account.

  ## Parameters
    - `conn`: The Plug connection.
    - `origin`: The ID of the account to transfer from.
    - `destination`: The ID of the account to transfer to.
    - `amount`: The amount to transfer.

  ## Returns
    - `201 Created` with the updated balances of both accounts on success.
    - `404 Not Found` if the origin account does not exist.
    - `422 Unprocessable Entity` if there are insufficient funds in the origin account.
    - `422 Unprocessable Entity` if the origin and destination accounts are the same.
  """
  def post_event(
        conn,
        %{"type" => "transfer", "origin" => origin, "amount" => amount, "destination" => destination}
      ) do
    # Create a Wallet struct representing the transfer transaction.
    wallet = %Wallet{
      origin: origin,
      destination: destination,
      amount: amount,
      signature: "transfer"
    }

    case BlockChain.transfer(wallet) do
      {:ok, transfer} ->
        conn |> put_status(201) |> json(transfer)
      {:error, :account_not_found} ->
        conn |> put_status(404) |> json(0)
      {:error, :insufficient_funds} ->
        conn |> put_status(422) |> json(%{error: "insufficient funds"})
      {:error, :same_account_transfer} ->
        conn |> put_status(422) |> json(%{error: "cannot transfer to the same account"})
    end
  end
end
