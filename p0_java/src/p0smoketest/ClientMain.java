package p0smoketest;

import java.io.IOException;
import java.net.Socket;
import java.util.ArrayList;
import java.util.concurrent.Semaphore;

public class ClientMain extends Thread {
    public static void main(String[] args) throws InterruptedException {
        int numThreads = 5;

        Semaphore semaphore = new Semaphore(numThreads);
        // take all the permits
        semaphore.acquire(numThreads);

        var threads = new ArrayList<ClientMain>();
        for (int i = 0; i < numThreads; i++) {
            var thread = new ClientMain();
            thread.semaphore = semaphore;
            thread.start();
            threads.add(thread);
        }

        for (int i = 0; i < numThreads; i++) {
            Thread.sleep(400);
            semaphore.release();
        }

        for (int i = 0; i < threads.size(); i++) {
            ClientMain th = threads.get(i);
            th.join();

            System.out.print(i + " Got bytes: ");
            for (byte b : th.data) {
                System.out.print(b + ", ");
            }
            System.out.println();
        }
    }

    byte[] data;
    Semaphore semaphore;

    @Override
    public void run() {
        try {
            var socket = new Socket("localhost", Main.PORT);

            // generate random bytes
            var bytes = new byte[8];
            for (int i = 0; i < bytes.length; i++) {
                bytes[i] = (byte) (Math.random() * 256);
            }

            semaphore.acquire();

            // write the bytes to the socket
            var out = socket.getOutputStream();
            out.write(bytes);
            socket.shutdownOutput();

            // Listen on the socket
            var in = socket.getInputStream();
            data = in.readAllBytes();

            // close the socket
            socket.close();
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}


