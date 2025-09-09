defmodule Broker do
  use GenServer

  @port 5000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, _socket} =
      case :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true]) do
        {:ok, socket} ->
          IO.puts("Servidor Teltonika escuchando en el puerto #{@port}")
          accept_loop(socket)
          {:ok, socket}

        {:error, reason} ->
          IO.puts("Error al iniciar el servidor: #{inspect(reason)}")
          {:stop, reason}
      end

    {:ok, %{}}
  end

  defp accept_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Task.start(fn -> handle_connection(client) end)
    accept_loop(socket)
  end

  defp handle_connection(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        parse_teltonika_frame(socket, data)

      # :gen_tcp.close(socket)

      {:error, reason} ->
        IO.puts("Error al recibir datos: #{inspect(reason)}")
        # :gen_tcp.close(socket)
    end
  end

  defp parse_teltonika_frame(socket, <<_header::binary-size(8), codec_id, count, rest::binary>>) do
    IO.puts("Reports count: #{count}")

    # Solo procesamos el primer AVL record
    # Timestamp
    <<
      _timestamp::unsigned-integer-size(64),
      # Priority
      _priority,
      # Latitude
      lat::signed-integer-size(32),
      # Longitude
      lon::signed-integer-size(32),
      # Speed
      speed::unsigned-integer-size(16),
      _rest::binary
    >> = rest

    latitude = lat / 10_000_000
    longitude = lon / 10_000_000

    IO.puts("📍 Latitud: #{latitude}, Longitud: #{longitude}, Speed: #{speed} km/h")

    ack = Base.decode16!("31")
    :gen_tcp.send(socket, ack)
    :ok
  end

  defp parse_teltonika_frame(socket, data) do
    IO.puts("Trama no reconocida: #{inspect(data)}")
    ack = Base.decode16!("00")
    :gen_tcp.send(socket, ack)
    :ok
  end

  def shutdown do
    GenServer.stop(__MODULE__)
  end
end
