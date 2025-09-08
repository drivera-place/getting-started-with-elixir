defmodule TeltonikaTCPCodec8Test do
  use ExUnit.Case

  doctest Protocols

  test "decode a IMEI" do
    # Arrange
    imei_hex = "000F333536333037303432343431303133"
    imei = "356307042441013"
    {:ok, binary} = Base.decode16(imei_hex, case: :mixed)
    IO.inspect(binary, label: "Binary")

    # Act
    {:ok, result} = Teltonika.TCPCodec8.read_imei(binary)
    expected =  Base.decode16(result)
    IO.inspect(Base.decode16(expected), label: "Expected")

    # Assert
    assert imei = expected
  end
end
