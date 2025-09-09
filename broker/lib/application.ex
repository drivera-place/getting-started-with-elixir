defmodule OnNodoBroker.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Broker.TCPAcceptor, port: 5000}
    ]

    opts = [strategy: :one_for_one, name: Broker.TCPAcceptor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
