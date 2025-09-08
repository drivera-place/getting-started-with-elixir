defmodule BrokerTest do
  use ExUnit.Case, async: true

  @port 5000

  #doctest Broker.Acceptor

  # We use a setup_all to start the supervisor only once for all tests in the module
  # This setup_all will run asynchronously thanks to `async: true`
  setup_all do

    Supervisor.start_child(Broker.TCPAcceptor.Supervisor, {Broker.TCPAcceptor, port: @port})

    # This is crucial so that the supervisor shuts down when the tests finish
    on_exit(fn ->
      Supervisor.stop(Broker.TCPAcceptor.Supervisor)
      :ok
    end)
  end

  test "Given a listening broker when client sends a codec id then report data then server responses ok" do

    # Arrange
    {:ok, socket} = :gen_tcp.connect(~c'localhost', @port, [:binary, active: false])

    # Act
    :gen_tcp.send(socket, "Codec ID\n")
    expected_result = :gen_tcp.recv(socket, 0, 500)
    :gen_tcp.send(socket, "Report\n")

    # Assert
    assert {:ok, _packet} = expected_result

    :gen_tcp.close(socket)
  end
end
