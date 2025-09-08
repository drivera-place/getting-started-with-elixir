defmodule Broker.TCPAcceptor do
  use GenServer

  require Logger

  @socket_timeout 5000

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(options) do
    port = Keyword.fetch!(options, :port)

    listen_options = [ # (2)
      :binary,
      active: true,
      exit_on_close: false,
      reuseaddr: true,
      backlog: 25
    ]

    case :gen_tcp.listen(port, listen_options) do # (3)
      {:ok, listen_socket} ->
        Logger.info("Started TCP server on port #{port}")
        send(self(), :accept) # (4)
        {:ok, listen_socket} # (5)

      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_info(:accept, listen_socket) do # (6)
    case :gen_tcp.accept(listen_socket) do # (7)

    {:ok, socket} ->

      {:ok, pid} = Broker.TCPConnection.start_link(socket) # (8)
      Logger.info("Accepted new connection, spawned process id: #{inspect(pid)}")
      :ok = :gen_tcp.controlling_process(socket, pid) # (9)
      send(self(), :accept) # (10)
      {:noreply, listen_socket}

    {:error, reason} ->
      Logger.error("Unable to accept connection: #{inspect(reason)}")
      {:stop, reason, listen_socket}
    end
  end

end
