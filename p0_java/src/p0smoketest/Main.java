package p0smoketest;

import java.io.IOException;
import java.net.ServerSocket;

public class Main {
    public static final int PORT = 9090;

    public static void main(String[] args) throws IOException {
	    var serverSocket = new ServerSocket(PORT);
        System.out.println("Listening on PORT " + PORT);

        while (true) {
            listenAndServe(serverSocket);
        }
    }

    private static void listenAndServe(ServerSocket serverSocket) throws IOException {
        var socket = serverSocket.accept();
        System.out.println("Accepted connection");

        var data = socket.getInputStream().readAllBytes();
        System.out.print("Read data: ");
        for (byte datum : data) {
            System.out.print(datum + ", ");
        }
        System.out.println();

        var outputStream = socket.getOutputStream();
        outputStream.write(data);
        System.out.println("Wrote data back to socket");

        socket.close();
        System.out.println("Closed socket");
    }
}
