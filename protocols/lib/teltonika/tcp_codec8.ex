defmodule Teltonika.TCPCodec8 do
  use Bitwise

  require Logger

  @moduledoc """
  Parser to identify Codec8 in Teltonika messages using the TCP protocol.
  Read more about the protocol here: https://wiki.teltonika-gps.com/view/Codec_8
  """

  @doc """
  Parses the received binary and returns the identified codec.

  ## Example

      iex> Teltonika.Codec8.parse(<<0, 0, 0, 8, 8, 1, 2, 3, 4, 5, 6, 7, 8>>)
      {:ok, 8}

  """

  defstruct [
    :preamble,
    :data_field_length,
    :codec_id,
    :number_of_data1,
    :avl_data,
    :number_of_data2,
    :crc16
  ]

  @doc """
  Extracts the IMEI from a binary Codec8 message where the first 2 bytes indicate the length in bytes of the IMEI, the rest of bytes is the IMEI itself.

  ## Example

      iex> Teltonika.TCPCodec8.read_imei(<<0x00, 0x08, 0x35, 0x31, 0x35, 0x31, 0x39, 0x30, 0x30, 0x30>>)
      {:ok, "51519000"}

  """

  def read_imei(<<imei_message::binary>>) do
    Logger.debug("IMEI message: #{Base.encode16(imei_message)}")

    case imei_message do
      <<length::unsigned-integer-size(16), imei::binary-size(length), _rest::binary>> ->
        Logger.debug("Decoded IMEI length: #{length} bytes")
        Logger.debug("Decoded IMEI ID: #{imei}")
        {:ok, imei}

      _ ->
        error_message = "Invalid IMEI format"
        Logger.error(error_message)
        # throw(:invalid_imei_format)
        {:error, error_message}
    end
  end

  def read_imei(<<length::unsigned-integer-size(16), imei::binary-size(length)>>) do
    Logger.debug("Decoded IMEI length: #{length} bytes")
    Logger.debug("Decoded IMEI ID: #{imei}")

    # Nothing to do, pattern matching did the job.

    {:ok, imei}
  end

  def read_imei(_), do: {:error, "Invalid IMEI format"}

  @doc """
  Accepts client data based on the Teltonika Codec8 protocol.
  ## Example

      iex> Teltonika.TCPCodec8.accept_client_data()
      {:ok, <<0, 1>>}
  """
  def accept_client_data() do
    {:ok, <<0, 1>>}
  end

  @doc """
  Denies client data based on the Teltonika Codec8 protocol.
  ## Example

      iex> Teltonika.TCPCodec8.deny_client_data()
      {:ok, <<0, 0>>}
  """
  def deny_client_data() do
    {:ok, <<0, 0>>}
  end

  def parse(<<message::binary>>) do
    Logger.debug("Report message: #{Base.encode16(message)}")

    <<
      crc16::unsigned-integer-size(16)
    >> = :binary.part(message, byte_size(message) - 2, 2)

    Logger.debug("CRC16: #{crc16}")

    # Logger.debug("Message size: #{byte_size(message)} bytes")
    # payload_to_check = :binary.part(message, 7, byte_size(message) - 11)
    # Logger.debug("Payload to check: #{Base.encode16(payload_to_check)}")
    # crc16_ibm = crc16_ibm(payload_to_check)
    # Logger.debug("Calculated CRC16/IBM: #{crc16_ibm}")

    <<
      # 4 bytes for preamble
      _preamble::binary-size(4),
      # 4 bytes for data field length
      _data_field_length::binary-size(4),
      # 1 byte for codec ID
      codec_id::binary-size(1),
      # 1 byte for number of data 1
      _number_of_data1::binary-size(1),
      rest::binary
    >> = message

    Logger.debug("Codec ID: #{Base.encode16(codec_id)}")

    <<
      # Timestamp
      timestamp::unsigned-integer-size(64),
      # Priority
      priority::unsigned-integer-size(8),
      # Latitude
      lat::signed-integer-size(32),
      # Longitude
      lon::signed-integer-size(32),
      # Altitude
      alt::unsigned-integer-size(16),
      _rest::binary
    >> = rest

    report = %Teltonika.TCPCodec8.Gps{
      timestamp: timestamp,
      priority: priority,
      latitude: lat / 10_000_000,
      longitude: lon / 10_000_000,
      altitude: alt
    }

    Logger.debug("Timestamp: #{report.timestamp}")
    Logger.debug("Priority: #{report.priority}")
    Logger.debug("Latitude: 📍 #{report.latitude}")
    Logger.debug("Longitude: 📍 #{report.longitude}")
    Logger.debug("Altitude: 📍 #{report.altitude}")

    {:ok, report}
  end

  def parse(_), do: {:error, "Invalid Codec8 message"}

  @doc """
  Calcula el CRC-16/IBM (también conocido como CRC-16-ANSI) de un binario.

  ## Ejemplo

    iex> Teltonika.TCPCodec8.crc16_ibm(<<1, 2, 3, 4>>)
    0x2189

  """
  def crc16_ibm(data) when is_binary(data) do
    crc16_ibm(data, 0x0000)
  end

  defp crc16_ibm(<<>>, crc), do: crc

  defp crc16_ibm(<<byte, rest::binary>>, crc) do
    crc =
      :lists.foldl(
        fn _, acc ->
          if (acc ^^^ byte &&& 1) == 1 do
            (acc >>> 1) ^^^ 0xA001 &&& 0xFFFF
          else
            acc >>> 1 &&& 0xFFFF
          end
        end,
        crc ^^^ byte,
        1..8
      )

    crc16_ibm(rest, crc)
  end
end
