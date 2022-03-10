# FinanceChain

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
# finance_chain




# Code Examples
```elixir
:sys.get_state(FinanceChain.BlockChain.Server)


FinanceChain.BlockChain.Server.get_blockchain(FinanceChain.BlockChain.Server)

FinanceChain.BlockChain.Server 
|> FinanceChain.BlockChain.Server.get_blockchain()


FinanceChain.BlockChain.Server 
|> FinanceChain.BlockChain.Server.get_blockchain() 
|> FinanceChain.BlockChain.total_amount(0)

FinanceChain.BlockChain.Server |> FinanceChain.BlockChain.Server.send_money(%{
  origin: 1,
  destiny: 0,
  amount: 1000
})


FinanceChain.BlockChain.Server |> FinanceChain.BlockChain.Server.send_money(%{ origin: 1, destination: 1, amount: 10})

```

--
# Reset state before starting tests

POST /reset

200 OK


--
# Get balance for non-existing account

GET /balance?account_id=1234

404 0


--
# Create account with initial balance

POST /event {"type":"deposit", "destination":"100", "amount":10}

201 {"destination": {"id":"100", "balance":10}}


--
# Deposit into existing account

POST /event {"type":"deposit", "destination":"100", "amount":10}

201 {"destination": {"id":"100", "balance":20}}


--
# Get balance for existing account

GET /balance?account_id=100

200 20

--
# Withdraw from non-existing account

POST /event {"type":"withdraw", "origin":"200", "amount":10}

404 0

--
# Withdraw from existing account

POST /event {"type":"withdraw", "origin":"100", "amount":5}

201 {"origin": {"id":"100", "balance":15}}

--
# Transfer from existing account

POST /event {"type":"transfer", "origin":"100", "amount":15, "destination":"300"}

201 {"origin": {"id":"100", "balance":0}, "destination": {"id":"300", "balance":15}}

--
# Transfer from non-existing account

POST /event {"type":"transfer", "origin":"200", "amount":15, "destination":"300"}

404 0

