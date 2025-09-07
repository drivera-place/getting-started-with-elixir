defmodule BrokerTest do
  use ExUnit.Case, async: true
  #alias IEx.Broker
  #doctest Router

  # Este módulo será el Supervisor para nuestro servidor TCP durante la prueba
  defmodule TestSupervisor do
    use Supervisor

    def start_link(_opts) do
      Supervisor.start_link(__MODULE__, [])
    end

    @impl true
    def init([]) do
      # Aquí es donde el servidor TCP del otro proyecto se inicia
      # Deberás reemplazar `TcpServer.Server` con el nombre real de tu módulo de servidor
      children = [
        %{
          id: TeltonikaServer,
          start: {TeltonikaServer, :start_link, []}
        }
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end

  # Usamos un setup_all para iniciar el supervisor una sola vez para todos los tests del módulo
  # Este setup_all correrá de manera asíncrona gracias al `async: true`
  setup_all do
    # Iniciamos el supervisor para el servidor TCP. El pid se pasa a los tests
    {:ok, pid} = Supervisor.start_child(TestSupervisor, nil)

    # Esto es crucial para que el supervisor se apague cuando terminen los tests
    on_exit(fn ->
      Supervisor.stop(pid)
      :ok
    end)

    # Devolvemos el pid del supervisor en el contexto para poder usarlo en los tests
    %{supervisor_pid: pid}
  end


  test "Testing start and listen on port" do

    # Arrange

    # Act
    {:ok, socket} = :gen_tcp.connect('localhost', 4000, [:binary, active: false])
    :gen_tcp.send(socket, "Hello, server!")
    expected_result = :gen_tcp.recv(socket, 0)

    # Assert
    assert expected_result == {:ok, _socket}

    #task = Task.async(fn -> expected_result = Broker.init() end)

    # case Task.yield(task, 500) || Task.shutdown(task) do

    #   {:ok, result} -> expected_result = result
    #   assert expected_result == {:ok, _socket}

    #   #{:ok, result} -> expected_result = result
    #   #nil -> expected_result = {:error, :timeout}
    # end

    # IO.puts("Broker started with PID: #{inspect(pid)}")
    # :timer.sleep(300)


  end
end
