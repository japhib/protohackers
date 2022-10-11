defmodule P0SmokeTestHelper do
  def connect() do
    host = 'localhost'
    port = P0SmokeTest.port!()

    sockets =
      1..1
      |> Task.async_stream(fn _ ->
        {:ok, socket} = :gen_tcp.connect(host, port, [:inet, :binary, {:packet, :raw}, {:active, false}])
        socket
      end)
      |> Enum.map(fn {:ok, socket} -> socket end)
      |> Enum.to_list()
      |> IO.inspect(label: "sockets")

    IO.puts("sockets connected. Writing data")

    Task.async_stream(sockets, fn socket ->
      :ok = :gen_tcp.send(socket, "Some Data2")
    end) |> Enum.to_list() |> IO.inspect(label: "write")

    Task.async_stream(sockets, fn socket ->
      :ok = :gen_tcp.shutdown(socket, :write)
    end) |> Enum.to_list() |> IO.inspect(label: "close for writing")

    Task.async_stream(sockets, fn socket ->
      do_recv(socket)
    end) |> Enum.to_list() |> IO.inspect(label: "listening")

    Task.async_stream(sockets, fn socket ->
      :gen_tcp.close(socket)
    end) |> Enum.to_list() |> IO.inspect(label: "close")

    IO.puts("done")
  end

  defp do_recv(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, msg} ->
        IO.inspect(msg, label: "Received client")
        # keep listening
        do_recv(socket)

      {:error, _} = error ->
        IO.inspect(error, label: "Received client")
    end
  end
end
