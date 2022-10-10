defmodule P0SmokeTestHelper do
  def connect() do
    host = 'localhost'
    {:ok, socket} = :gen_tcp.connect(host, P0SmokeTest.port!(), [:inet, :binary, {:packet, :raw}, {:active, false}])
    :ok = :gen_tcp.send(socket, "Some Data")
    :socket.info() |> IO.inspect(label: "socket general info")
    :socket.info(socket) |> IO.inspect(label: "socket info")
    :ok = :gen_tcp.shutdown(socket, :write)
    IO.inspect(socket, label: "socket")

    case :gen_tcp.recv(socket, 0) do
      msg -> IO.inspect(msg, label: "Received client")
    end

    # :ok = :gen_tcp.close(socket)
    IO.puts("done")
  end
end
