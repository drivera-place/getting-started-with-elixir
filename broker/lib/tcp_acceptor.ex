defmodule Broker.TCPAcceptor do
  use GenServer

  require Logger

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(options) do
    port = Keyword.fetch!(options, :port)

    # (2)
    listen_options = [
      :binary,
      active: true,
      exit_on_close: false,
      reuseaddr: true,
      backlog: 25
    ]

    # (3)
    case :gen_tcp.listen(port, listen_options) do
      {:ok, listen_socket} ->
        Logger.info("Started TCP server on port #{port}")
        # (4)
        send(self(), :accept)
        # (5)
        {:ok, listen_socket}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  # (6)
  def handle_info(:accept, listen_socket) do
    # (7)
    case :gen_tcp.accept(listen_socket) do
      {:ok, socket} ->
        # (8)
        {:ok, pid} = Broker.TCPConnection.start_link(socket)
        Logger.info("Accepted new connection, spawned process id: #{inspect(pid)}")
        # (9)
        :ok = :gen_tcp.controlling_process(socket, pid)
        # (10)
        send(self(), :accept)
        {:noreply, listen_socket}

      {:error, reason} ->
        Logger.error("Unable to accept connection: #{inspect(reason)}")
        {:stop, reason, listen_socket}
    end
  end
end
