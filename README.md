# FinanceChain

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
# Main problem

A financial api where it is possible to add remove credits and with specific endpoints for use. When I received the problem, I didn't really know what I could use or how I could solve it. In that I remembered that I was studying about blockchains and had also read some Erlang Org Articles, that both Erlang and Elixir could solve these problems. I sought to study Elixir in parallel despite knowing the syntax of Elixir/Erlang theory and practice are different things and I needed both in this implementation. I ask for your patience in finding errors. I ask you to report it in ISSUES.

# finance_chain
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

