defmodule Teltonika.TCPCodec8 do
  require Logger

  @moduledoc """
  Parser para identificar el Codec en mensajes Teltonika TCP.
  """

  @doc """
  Parsea el binario recibido y retorna el codec identificado.

  ## Ejemplo

      iex> Teltonika.Codec8.parse(<<0, 0, 0, 8, 8, 1, 2, 3, 4, 5, 6, 7, 8>>)
      {:ok, 8}

  """

  defstruct [:preamble, :data_field_length, :codec_id, :number_of_data1, :avl_data, :number_of_data2, :crc16]

  def read_imei(<<length::signed-integer-size(2), imei_rest::binary>>) do
    Logger.info("Length: #{inspect(length)}")

    <<
      imei::signed-integer-size(length)
    >> = imei_rest

    imei_str = Integer.to_string(imei)
    Logger.info("IMEI: #{imei_str}")

    {:ok, imei_str}
  end
end
