defmodule Teltonika.TCPCodec8.ParseTest do
  use ExUnit.Case

  require Logger

  doctest Protocols

  test "decode a TCP Codec8 message" do
    # Arrange
    tcp_codec8_hex =
      "000000000000008C08010000013FEB55FF74000F0EA850209A690000940000120000001E09010002000300040016014703F0001504C8000C0900730A00460B00501300464306D7440000B5000BB60007422E9F180000CD0386CE000107C700000000F10000601A46000001344800000BB84900000BB84A00000BB84C00000000024E0000000000000000CF00000000000000000100003FCA"

    expected_report = %Teltonika.TCPCodec8.Gps{
      timestamp: 1_374_042_849_140,
      priority: 0,
      latitude: 25.2618832,
      longitude: 54.6990336,
      altitude: 148
    }

    {_ok, binary} = Base.decode16(tcp_codec8_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.parse(binary) do
        {:ok, result} ->
          result

        {:error, result} ->
          result
      end

    Logger.debug("TCP Codec8 report message parsed: #{inspect(result)}")

    # Assert
    assert expected_report == result
  end

  @tag :skip
  test "tries to decode an invalid TCP Codec8 message" do
    # Arrange
    invalid_tcp_codec8_hex =
      "000000000000008C08010000013FEB55FF74000F0EA850209A690000940000120000001E09010002000300040016014703F0001504C8000C0900730A00460B00501300464306D7440000B5000BB60007422E9F180000CD0386CE000107C700000000F10000601A46000001344800000BB84900000BB84A00000BB84C00000000024E0000000000000000CF00000000000000000100003F"

    expected_message = "Invalid Codec8 message"

    {_ok, binary} = Base.decode16(invalid_tcp_codec8_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.parse(binary) do
        {:ok, result} ->
          result

        {:error, result} ->
          result
      end

    Logger.debug("TCP Codec8 report message parsed: #{inspect(result)}")

    # Assert
    assert ^expected_message = result
  end
end
