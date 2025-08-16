defmodule TeltonikaServer do
  use GenServer

  @port 5000

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, _socket} = :gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true])
    IO.puts("Servidor Teltonika escuchando en el puerto #{@port}")
    accept_loop()
    {:ok, %{}}
  end

  defp accept_loop() do
    {:ok, socket} = :gen_tcp.accept(:gen_tcp.listen(@port, [:binary, packet: 0, active: false, reuseaddr: true]))
    Task.start(fn -> handle_connection(socket) end)
    accept_loop()
  end

  defp handle_connection(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        parse_teltonika_frame(data)
        :gen_tcp.close(socket)

      {:error, reason} ->
        IO.puts("Error al recibir datos: #{inspect(reason)}")
    end
  end

  defp parse_teltonika_frame(<<_header::binary-size(8), codec_id, count, rest::binary>>) do
    # Solo procesamos el primer AVL record
    <<_timestamp::unsigned-integer-size(64),
      _priority,
      lat::signed-integer-size(32),
      lon::signed-integer-size(32),
      speed::unsigned-integer-size(16),
      _rest::binary>> = rest

    latitude = lat / 10_000_000
    longitude = lon / 10_000_000

    IO.puts("📍 Latitud: #{latitude}, Longitud: #{longitude}, Velocidad: #{speed} km/h")
  end

  defp parse_teltonika_frame(data) do
    IO.puts("Trama no reconocida: #{inspect(data)}")
  end
end
