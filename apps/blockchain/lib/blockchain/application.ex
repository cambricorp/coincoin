defmodule Blockchain.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.fetch_env!(:blockchain, :port)

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Blockchain.Worker.start_link(a1, a2, a3)
      # worker(Blockchain.Worker, [arg1, arg2, arg3]),
      worker(Blockchain.Chain, []),
      worker(Blockchain.Mempool, []),

      # P2P processes
      worker(Blockchain.P2P.Peers, []),
      supervisor(Task.Supervisor, [
        [name: Blockchain.P2P.Server.TasksSupervisor]
      ]),
      worker(Task, [Blockchain.P2P.Server, :accept, [port]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blockchain.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
