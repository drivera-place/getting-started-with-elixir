def start(_type, _args) do
  children = [
    TeltonikaServer
  ]

  opts = [strategy: :one_for_one, name: TeltonikaServer.Supervisor]
  Supervisor.start_link(children, opts)
end
