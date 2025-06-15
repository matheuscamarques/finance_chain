defmodule FinanceChain.BlockChain do
  @moduledoc """
  O módulo de contexto e a API pública para interagir com a FinanceChain.
  """
  alias FinanceChain.BlockChain.{Chain, Server, Wallet}

  # Wrapper para o GenServer. O nome do processo é definido no Supervisor.
  @server_name Server

  # =================================================================
  #  API PÚBLICA
  # =================================================================

  def reset, do: Server.reset_blockchain(@server_name)

  def get_balance(account_id) do
    chain_state = Server.get_blockchain(@server_name)
    all_accounts = Chain.all_accounts(chain_state)

    if MapSet.member?(all_accounts, account_id) do
      balance = Chain.total_amount(chain_state, account_id)
      {:ok, balance}
    else
      # Contrato: conta não existe, retorna erro com saldo 0
      {:error, 0}
    end
  end

  def deposit(%Wallet{} = wallet) do
    case Server.send_event(@server_name, wallet) do
      :ok ->
        # get_balance agora retorna {:ok, _} ou {:error, _}, mas depois de um depósito, sempre será :ok
        {:ok, new_balance} = get_balance(wallet.destination)
        # Contrato: A resposta deve ser um mapa com a chave "destination"
        {:ok, %{destination: %{id: wallet.destination, balance: new_balance}}}
    end
  end

  def withdraw(%Wallet{origin: origin, amount: amount_to_withdraw} = wallet) do
    case get_balance(origin) do
      {:error, _balance} ->
        # Contrato: conta não existe
        {:error, :account_not_found}
      {:ok, current_balance} when current_balance < amount_to_withdraw ->
        # Contrato: saldo insuficiente
        {:error, :insufficient_funds}
      {:ok, _current_balance} ->
        # Lógica de sucesso
        Server.send_event(@server_name, wallet)
        {:ok, new_balance} = get_balance(origin)
        # Contrato: A resposta deve ser um mapa com a chave "origin"
        {:ok, %{origin: %{id: wallet.origin, balance: new_balance}}}
    end
  end

  def transfer(
        %Wallet{origin: origin, destination: destination, amount: amount_to_transfer} = wallet
      ) do
    # A estrutura `with` é ideal para encadear operações que podem falhar.
    with {:ok, current_balance} <- get_balance(origin),
         true <- current_balance >= amount_to_transfer,
         false <- origin == destination do
      # Bloco DO: executado apenas se todas as cláusulas acima passarem
      Server.send_event(@server_name, wallet)
      {:ok, origin_balance} = get_balance(origin)
      # A conta de destino pode não existir, então pegamos o saldo dela de qualquer forma
      chain_state = Server.get_blockchain(@server_name)
      destination_balance = Chain.total_amount(chain_state, destination)
      # Contrato: A resposta deve ser um mapa com "origin" e "destination"
      {:ok,
       %{
         origin: %{id: origin, balance: origin_balance},
         destination: %{id: destination, balance: destination_balance}
       }}
    else
      # Bloco ELSE: executado se qualquer cláusula acima falhar
      {:error, _} -> {:error, :account_not_found}
      false -> {:error, :insufficient_funds}
      true -> {:error, :same_account_transfer}
    end
  end
end
