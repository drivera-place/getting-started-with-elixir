defmodule Teltonika.TCPCodec8.ReadImeiTest do
  use ExUnit.Case

  require Logger

  doctest Protocols

  test "decode an IMEI" do
    # Arrange
    imei_hex = "000F333536333037303432343431303133"
    expected_imei = "356307042441013"
    {_ok, binary} = Base.decode16(imei_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.read_imei(binary) do
        {:ok, result} ->
          result |> to_string()

        {:error, result} ->
          result |> to_string()
      end

    Logger.debug("IMEI parsed: #{result}")

    # Assert
    assert ^expected_imei = result
  end

  test "tries to decode a longer IMEI message" do
    # Arrange
    imei_hex = "000F33353633303730343234343130313300"
    expected_imei = "356307042441013"
    {_ok, binary} = Base.decode16(imei_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.read_imei(binary) do
        {:ok, result} ->
          result |> to_string()

        {:error, result} ->
          result |> to_string()
      end

    Logger.debug("IMEI parsed: #{result}")

    # Assert
    assert ^expected_imei = result
  end

  test "tries to decode a shorter IMEI message" do
    # Arrange
    imei_hex = "000F33353633303730343234343130"
    expected_imei = "Invalid IMEI format"
    {_ok, binary} = Base.decode16(imei_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.read_imei(binary) do
        {:ok, result} ->
          result |> to_string()

        {:error, result} ->
          result |> to_string()
      end

    Logger.debug("IMEI parsed: #{result}")

    # Assert
    assert ^expected_imei = result
  end

  test "tries to decode an absent IMEI message" do
    # Arrange
    imei_hex = "000F"
    expected_imei = "Invalid IMEI format"
    {_ok, binary} = Base.decode16(imei_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.read_imei(binary) do
        {:ok, result} ->
          result |> to_string()

        {:error, result} ->
          result |> to_string()
      end

    Logger.debug("IMEI parsed: #{result}")

    # Assert
    assert ^expected_imei = result
  end

  test "tries to decode an empty IMEI message" do
    # Arrange
    imei_hex = ""
    expected_imei = "Invalid IMEI format"
    {_ok, binary} = Base.decode16(imei_hex, case: :mixed)

    # Act
    result =
      case Teltonika.TCPCodec8.read_imei(binary) do
        {:ok, result} ->
          result |> to_string()

        {:error, result} ->
          result |> to_string()
      end

    Logger.debug("IMEI parsed: #{result}")

    # Assert
    assert ^expected_imei = result
  end
end
