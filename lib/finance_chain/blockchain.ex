
defmodule FinanceChain.BlockChain do
  @moduledoc """
  The context module and public API for interacting with the concurrent FinanceChain blockchain.
  It orchestrates interactions with individual `AccountServer` processes.
  """
  alias FinanceChain.BlockChain.{AccountServer, Wallet}

  # =================================================================
  #  PUBLIC API
  # =================================================================

  @doc """
  Retrieves the current balance for a given `account_id`.

  If the account does not exist (no `AccountServer` process found), it returns an error
  indicating an account not found with a balance of 0, adhering to the contract.

  ## Parameters
    - `account_id`: The ID of the account.

  ## Returns
    - `{:ok, balance}` if the account exists and its balance can be retrieved.
    - `{:error, 0}` if the account does not exist.
  """
  def get_balance(account_id) do
    case find_account_server(account_id) do
      nil ->
        # Contract: account does not exist, return error with balance 0
        {:error, 0}

      pid ->
        AccountServer.get_balance(pid)
    end
  end

  @doc """
  Processes a deposit transaction.

  This function finds or starts an `AccountServer` for the destination account,
  then adds the deposit transaction to that account's blockchain.

  ## Parameters
    - `wallet`: A `Wallet` struct representing the deposit. The `destination` field is mandatory.

  ## Returns
    - `{:ok, %{destination: %{id: destination_id, balance: new_balance}}}` on successful deposit.
  """
  def deposit(%Wallet{destination: destination} = wallet) do
    # Find or start the process for the destination account.
    with {:ok, pid} <- find_or_start_account_server(destination) do
      # Add the deposit transaction to the account's blockchain.
      AccountServer.add_transaction(pid, wallet)

      # Get the new balance after the transaction.
      {:ok, new_balance} = AccountServer.get_balance(pid)

      # Contract: The response must be a map with the "destination" key.
      {:ok, %{destination: %{id: destination, balance: new_balance}}}
    end
  end

  @doc """
  Processes a withdrawal transaction.

  It first checks if the origin account exists and has sufficient funds.
  If valid, it adds the withdrawal transaction to the origin account's blockchain.

  ## Parameters
    - `wallet`: A `Wallet` struct representing the withdrawal. The `origin` and `amount` fields are mandatory.

  ## Returns
    - `{:ok, %{origin: %{id: origin_id, balance: new_balance}}}` on successful withdrawal.
    - `{:error, :account_not_found}` if the origin account does not exist.
    - `{:error, :insufficient_funds}` if the origin account has insufficient funds.
  """
  def withdraw(%Wallet{origin: origin, amount: amount_to_withdraw} = wallet) do
    with {:ok, current_balance} <- get_balance(origin),
         true <- current_balance >= amount_to_withdraw,
         # CORRECTION:
         # 1. We call `find_account_server` and assign the result (pid or nil) to `pid`.
         # 2. In a new clause, we ensure that `pid` is not `nil`.
         pid = find_account_server(origin),
         true <- not is_nil(pid) do
      # Success logic
      AccountServer.add_transaction(pid, wallet)
      # We need to fetch the balance again after the transaction
      {:ok, new_balance} = get_balance(origin)
      # Contract: The response must be a map with the "origin" key
      {:ok, %{origin: %{id: origin, balance: new_balance}}}
    else
      # ELSE block: handles failures
      # get_balance failed and returned error balance 0
      {:error, 0} -> {:error, :account_not_found}
      # get_balance failed for another reason
      {:error, _} -> {:error, :account_not_found}
      # balance check failed
      false -> {:error, :insufficient_funds}
    end
  end

  @doc """
  Processes a transfer transaction between two accounts.

  It verifies the origin account's existence, sufficient funds, and ensures
  the origin and destination accounts are not the same. If all checks pass,
  it adds the transaction to both the origin and destination accounts' blockchains.

  ## Parameters
    - `wallet`: A `Wallet` struct representing the transfer. The `origin`, `destination`,
                and `amount` fields are mandatory.

  ## Returns
    - `{:ok, %{origin: %{...}, destination: %{...}}}` on successful transfer.
    - `{:error, :account_not_found}` if the origin account does not exist.
    - `{:error, :insufficient_funds}` if the origin account has insufficient funds.
    - `{:error, :same_account_transfer}` if the origin and destination accounts are the same.
  """
  def transfer(
        %Wallet{origin: origin, destination: destination, amount: amount_to_transfer} = wallet
      ) do
    with {:ok, origin_balance} <- get_balance(origin),
         true <- origin_balance >= amount_to_transfer,
         false <- origin == destination, # Prevent transfer to the same account
         # Find the sender's process
         {:ok, origin_pid} <- {:ok, find_account_server(origin)},
         # Find or start the recipient's process
         {:ok, destination_pid} <- find_or_start_account_server(destination) do
      # DO block: executed only if all the above clauses pass
      # Execute both transactions concurrently (add to respective blockchains)
      AccountServer.add_transaction(origin_pid, wallet)
      AccountServer.add_transaction(destination_pid, wallet)

      # Get the new balances for both accounts
      {:ok, new_origin_balance} = get_balance(origin)
      {:ok, new_destination_balance} = get_balance(destination)

      {:ok,
       %{
         origin: %{id: origin, balance: new_origin_balance},
         destination: %{id: destination, balance: new_destination_balance}
       }}
    else
      # ELSE block: handles failures from the `with` clauses
      {:error, _} -> {:error, :account_not_found}
      false -> {:error, :insufficient_funds}
      true -> {:error, :same_account_transfer}
    end
  end

  # =================================================================
  #  Internal Helper Functions
  # =================================================================

  @doc """
  Attempts to find an account process registered in the `FinanceChain.Registry`.

  ## Parameters
    - `account_id`: The ID of the account to look up.

  ## Returns
    - The PID of the `AccountServer` process if found.
    - `nil` if no process is registered for the given `account_id`.
  """
  def find_account_server(account_id) do
    case Registry.lookup(FinanceChain.Registry, account_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  @doc """
  Finds an existing account process or, if it doesn't exist, requests the
  `DynamicSupervisor` to create a new one for the specified `account_id`.

  ## Parameters
    - `account_id`: The ID of the account to find or start.

  ## Returns
    - `{:ok, pid}` if the account process is found or successfully started.
    - `{:error, :unknown_error}` if an unexpected error occurs during startup.
  """
  def find_or_start_account_server(account_id) do
    case find_account_server(account_id) do
      nil ->
        # Process does not exist, let's start it
        spec = {AccountServer, account_id}
        DynamicSupervisor.start_child(FinanceChain.AccountSupervisor, spec)

      # If the pid was directly returned by find_account_server
      pid when is_pid(pid) -> {:ok, pid}

      # Catch-all for any other unexpected results
      _ -> {:error, :unknown_error}
    end
  end

  @doc """
  Resets the state of the entire blockchain by terminating and restarting
  the `DynamicSupervisor` responsible for managing account processes.
  This effectively clears the state of all accounts in the system.

  ## Returns
    - `:ok` if the reset operation is successful.
    - `{:error, :supervisor_not_running}` if the main supervisor is not found.
    - `{:error, :unknown_error}` for any other unexpected error during reset.
  """
  def reset() do
    # The name of our main supervisor, defined in application.ex
    main_supervisor = FinanceChain.Supervisor

    # The ID of the child we want to restart (the name we gave to the DynamicSupervisor)
    child_id = FinanceChain.AccountSupervisor

    # 1. Terminate the DynamicSupervisor and, consequently, all its children (the accounts)
    result = Supervisor.terminate_child(main_supervisor, child_id)

    # When processes die, they are automatically removed from the Registry.

    # 2. Start a new, clean DynamicSupervisor
    Supervisor.restart_child(main_supervisor, child_id)

    # Return :ok if termination was successful
    case result do
      :ok -> :ok
      {:error, :not_found} -> {:error, :supervisor_not_running}
      _ -> {:error, :unknown_error}
    end
  end
end
