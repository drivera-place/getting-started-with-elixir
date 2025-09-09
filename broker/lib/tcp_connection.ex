defmodule Broker.TCPConnection do
  use GenServer

  require Logger

  # ToDo: Inject the protocols codecs modules to be used according withe transport protocol/port/vendor.
  @spec start_link(:gen_tcp.socket()) :: GenServer.on_start()
  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  defstruct [:socket, buffer: <<>>]

  @impl true
  def init(socket) do
    state = %__MODULE__{socket: socket}
    {:ok, state}
  end

  @impl true
  def handle_info(message, state)

  def handle_info({:tcp_closed, socket}, %__MODULE__{socket: socket} = state) do
    Logger.info("TCP connection closed")
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, socket, reason}, %__MODULE__{socket: socket} = state) do
    Logger.error("TCP connection error: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  def handle_info({:tcp, socket, data}, %__MODULE__{socket: socket} = state) do
    state = update_in(state.buffer, &(&1 <> data))
    state = receive_data(state)
    {:noreply, state}
  end

  defp receive_data(state) do
    Logger.info("Data processed by PID: #{inspect(self())}")
    Logger.debug("Received data: #{inspect(state.buffer)}")

    # ToDo: Protocol, Codec ID and IMEI identification would go here

    # ToDo: Sending ACK back to client, only after Codec ID is identified.
    # We may send NACK back for every unknown Codec ID.

    case :gen_tcp.send(state.socket, "ACK\n") do
      :ok ->
        %{state | buffer: <<>>}

      # ToDo: Here would go the receiving of next report messages.
      # then we would close the connection ending the session.

      {:error, reason} ->
        Logger.error("Connection error: #{inspect(reason)}")
        state
    end
  end
end
