import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :finance_chain, FinanceChainWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "v64mhVv8enXMRAF4e/r6PQ5ZYhVMxqcNzLTHHNkVuzIix4Ue7lP/0h/X6y14gngz",
  server: false

# In test we don't send emails.
config :finance_chain, FinanceChain.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
