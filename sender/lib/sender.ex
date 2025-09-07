defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @port 5000
  @host "localhost"

  def connect(hex_string) do
    {:ok, socket} = :gen_tcp.connect(String.to_charlist(@host), @port, [:binary, active: false])
    data = Base.decode16!(hex_string)

    :gen_tcp.send(socket, data)
    {:ok} = confirm_accept(socket)
    {:ok} = send_data(socket)
    :gen_tcp.close(socket)

  end

  def send_data(socket) do
    IO.puts("Sending data...")
    data =  "000000000000008c08010000013feb55ff74000f0ea850209a690000940000120000001e09010002000300040016014703f0001504c8000c0900730a00460b00501300464306d7440000b5000bb60007422e9f180000cd0386ce000107c700000000f10000601a46000001344800000bb84900000bb84a00000bb84c00000000024e0000000000000000cf00000000000000000100003fca"
    IO.puts("Sending data: #{inspect(data)}")
    :gen_tcp.send(socket, data)
    :ok
  end

  def confirm_accept(socket) do
    case :gen_tcp.recv(socket, 4, 5000) do

      {:ok, <<0, 0, 0, 1>>} ->
        IO.puts("Positive ACK received")
        :ok

      {:ok, <<0, 0, 0, 0>>} ->
        IO.puts("Negative ACK received")
        {:error, :negative_ack}

      {:ok, <<0>>} ->
       IO.puts("Negative ACK received")
        {:error, :negative_ack}

      {:error, :timeout} ->
        IO.puts("Server did not reply, timeout waiting for ACK")
        {:error, :timeout}

      {:error, reason} ->
        IO.puts("Error receiving ACK: #{inspect(reason)}")
        {:error, reason}

      {:error, :closed} ->
        IO.puts("Connection closed by server")
        {:error, :closed}
    end
  end

end
