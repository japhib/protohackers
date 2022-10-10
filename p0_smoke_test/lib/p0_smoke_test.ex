defmodule P0SmokeTest do
  @moduledoc """
  0: Smoke Test

  Deep inside Initrode Global's enterprise management framework lies a component
  that writes data to a server and expects to read the same data back. (Think of
  it as a kind of distributed system delay-line memory). We need you to write
  the server to echo the data back.

  Accept TCP connections.

  Whenever you receive data from a client, send it back unmodified.

  Make sure you don't mangle binary data, and that you can handle at least 5
  simultaneous clients.

  Once the client has finished sending data to you it shuts down its sending
  side. Once you've reached end-of-file on your receiving side, and sent back
  all the data you've received, close the socket so that the client knows you've
  finished. (This point trips up a lot of proxy software, such as ngrok; if
  you're using a proxy and you can't work out why you're failing the check, try
  hosting your server in the cloud instead).

  Your program will implement the TCP Echo Service from RFC 862.

  https://protohackers.com/problem/0
  """

  use Application
  require Logger

  @port 9090 # Application.compile_env!(:p0_smoke_test, :port)

  def port!(), do: @port

  @impl true
  def start(_type, _args) do
    {:ok, listen_socket} = :gen_tcp.listen(@port, [:binary, {:packet, 0}, {:active, false}])

    Logger.info("Serving on port #{@port}")
    Task.start(fn -> listen_and_serve(listen_socket) end)
  end

  defp listen_and_serve(listen_socket) do
    with {:ok, socket} <- :gen_tcp.accept(listen_socket) do
      # Spin off new process to handle connection
      Task.start(fn -> serve_socket(socket) end)
    end
  after
    listen_and_serve(listen_socket)
  end

  defp serve_socket(socket) do
    case read_socket(socket) do
      {:ok, binary} ->
        IO.puts("got data: " <> inspect(binary))
        send_socket(socket, binary)
        # :ok = :gen_tcp.shutdown(socket, :write)

      error ->
        Logger.error("Error reading socket: #{inspect(error)}")
    end
  end

  defp read_socket(socket, binaries \\ []) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, binary} ->
        # Got some data - keep receiving
        read_socket(socket, [binaries, binary])

      {:error, :closed} ->
        # Socket closed - convert iodata to single binary and return
        {:ok, IO.iodata_to_binary(binaries)}
    end
  end

  defp send_socket(socket, binary) do
    case :gen_tcp.send(socket, binary) do
      :ok ->
        Logger.info("Sent data back: " <> inspect(binary))
        :ok

      error ->
        Logger.error("Error sending data back: " <> inspect(error))
    end
  end
end
