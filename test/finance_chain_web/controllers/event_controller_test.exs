defmodule FinanceChainWeb.EventControllerTest do
  use FinanceChainWeb.ConnCase, async: true

  # Importamos as funções do nosso contexto para facilitar a criação de dados
  alias FinanceChain.BlockChain

  # O bloco `setup` é executado antes de cada teste neste `describe`.
  # Isso garante que cada teste comece com um estado limpo e não interfira nos outros.
  setup do
    # Reseta a blockchain para o estado inicial antes de cada teste.
    BlockChain.reset()
    :ok
  end

  describe "POST /reset" do
    test "resets the application state", %{conn: conn} do
      # Primeiro, fazemos um depósito para garantir que o estado não está vazio.
      deposit_payload = %{"type" => "deposit", "destination" => "100", "amount" => 10}
      post(conn, "/event", deposit_payload)

      # Agora, chamamos o endpoint de reset
      conn = post(conn, "/reset")

      # Verificamos se o status da resposta é 200 OK
      assert conn.status == 200
      # Verificamos se o corpo da resposta é o texto "OK"
      assert conn.resp_body == "OK"

      # Para confirmar o reset, tentamos buscar o saldo da conta que criamos.
      # A resposta deve ser 404 (Não Encontrado), pois a conta não existe mais.
      conn = get(conn, "/balance?account_id=100")
      assert conn.status == 404
    end
  end

  describe "GET /balance" do
    test "returns 404 for a non-existing account", %{conn: conn} do
      conn = get(conn, "/balance?account_id=1234")

      assert conn.status == 404
      # Verificamos se a resposta JSON é o número 0, conforme o contrato.
      assert json_response(conn, 404) == 0
    end

    test "returns 200 and the correct balance for an existing account", %{conn: conn} do
      # Primeiro, criamos uma conta com um saldo
      deposit_payload = %{"type" => "deposit", "destination" => "100", "amount" => 50}
      post(conn, "/event", deposit_payload)

      # Agora, buscamos o saldo dessa conta
      conn = get(conn, "/balance?account_id=100")

      assert conn.status == 200
      assert json_response(conn, 200) == 50
    end
  end

  describe "POST /event" do
    # --- Testes de Depósito ---
    test "creates an account with an initial balance on deposit", %{conn: conn} do
      payload = %{"type" => "deposit", "destination" => "100", "amount" => 10}
      conn = post(conn, "/event", payload)

      assert conn.status == 201
      # O corpo da resposta deve corresponder exatamente ao contrato esperado.
      assert json_response(conn, 201) == %{
               "destination" => %{"id" => "100", "balance" => 10}
             }
    end

    test "deposits into an existing account", %{conn: conn} do
      # Primeiro depósito
      post(conn, "/event", %{"type" => "deposit", "destination" => "100", "amount" => 10})

      # Segundo depósito na mesma conta
      payload = %{"type" => "deposit", "destination" => "100", "amount" => 15}
      conn = post(conn, "/event", payload)

      assert conn.status == 201
      assert json_response(conn, 201) == %{
               "destination" => %{"id" => "100", "balance" => 25}
             }
    end

    # --- Testes de Saque (Withdraw) ---
    test "returns 404 when withdrawing from a non-existing account", %{conn: conn} do
      payload = %{"type" => "withdraw", "origin" => "999", "amount" => 10}
      conn = post(conn, "/event", payload)

      assert conn.status == 404
      assert json_response(conn, 404) == 0
    end

    test "returns 422 when withdrawing with insufficient funds", %{conn: conn} do
      # Cria uma conta com 10
      post(conn, "/event", %{"type" => "deposit", "destination" => "100", "amount" => 10})
      # Tenta sacar 20
      payload = %{"type" => "withdraw", "origin" => "100", "amount" => 20}
      conn = post(conn, "/event", payload)

      assert conn.status == 422
      assert json_response(conn, 422) == %{"error" => "insufficient funds"}
    end

    test "withdraws from an existing account successfully", %{conn: conn} do
      # Cria uma conta com 20
      post(conn, "/event", %{"type" => "deposit", "destination" => "100", "amount" => 20})
      # Saca 5
      payload = %{"type" => "withdraw", "origin" => "100", "amount" => 5}
      conn = post(conn, "/event", payload)

      assert conn.status == 201
      assert json_response(conn, 201) == %{"origin" => %{"id" => "100", "balance" => 15}}
    end

    # --- Testes de Transferência ---
    test "transfers successfully between two existing accounts", %{conn: conn} do
      # Cria conta de origem com 50
      post(conn, "/event", %{"type" => "deposit", "destination" => "100", "amount" => 50})
      # Cria conta de destino com 10
      post(conn, "/event", %{"type" => "deposit", "destination" => "200", "amount" => 10})

      # Transfere 20 da conta 100 para a 200
      payload = %{
        "type" => "transfer",
        "origin" => "100",
        "destination" => "200",
        "amount" => 20
      }
      conn = post(conn, "/event", payload)

      assert conn.status == 201
      assert json_response(conn, 201) == %{
               "origin" => %{"id" => "100", "balance" => 30},
               "destination" => %{"id" => "200", "balance" => 30}
             }
    end

    test "returns 404 when transferring from a non-existing account", %{conn: conn} do
      payload = %{
        "type" => "transfer",
        "origin" => "999", # Conta não existe
        "destination" => "200",
        "amount" => 15
      }
      conn = post(conn, "/event", payload)

      assert conn.status == 404
      assert json_response(conn, 404) == 0
    end
  end
end
