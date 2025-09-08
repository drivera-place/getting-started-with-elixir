defmodule Teltonika.TCPCodec8 do
  @moduledoc """
  Parser para identificar el Codec en mensajes Teltonika TCP.
  """

  @doc """
  Parsea el binario recibido y retorna el codec identificado.

  ## Ejemplo

      iex> Teltonika.Codec8.parse(<<0, 0, 0, 8, 8, 1, 2, 3, 4, 5, 6, 7, 8>>)
      {:ok, 8}

  """
  def parse(<<_len::32, codec::8, _rest::binary>>) do
    {:ok, codec}
  end

  def parse(_), do: {:error, :invalid_format}
end
