#include <stdio.h>
#include <stdbool.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define PORT 9090

int main() {
    // create server socket
    int server_socket = socket(PF_INET, SOCK_STREAM, 0);
    if (server_socket == -1) {
        perror("error opening socket");
        return 1;
    }

//    // Set SO_REUSEADDR | SO_REUSEPORT on socket
//    int setsockopt_value = 1;
//    int setsockopt_result = setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &setsockopt_value, sizeof(setsockopt_value));
//    if (setsockopt_result == -1) {
//        perror("error in setsockopt");
//        return 1;
//    }

    // Set port
    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);
    int bind_result = bind(server_socket, (const struct sockaddr *) &address, sizeof(address));
    if (bind_result == -1) {
        perror("bind error");
        return 1;
    }

    // listen for connections
    int listen_result = listen(server_socket, 16);
    if (listen_result == -1) {
        perror("listen error");
        return 1;
    }

    printf("Listening on port %d\n", PORT);

    int byte_buf_size = 1024;
    uint8_t *byte_buf = (uint8_t*) malloc(byte_buf_size);

    while (true) {
        // Reset the byte buffer offset
        int byte_buf_offset = 0;

        // accept connection
        socklen_t addrlen = sizeof(address);
        int socket = accept(server_socket, (struct sockaddr *) &address, &addrlen);
        if (socket == -1) {
            perror("Socket accept error");
            continue;
        }

        printf("Accepted socket. Reading ...\n");

        // Read until EOF
        uint8_t readbuf[1024];
        while (true) {
            ssize_t read_result = read(socket, readbuf, 1024);
            if (read_result == -1) {
                perror("read error");
            } else if (read_result == 0) {
                // EOF
                break;
            } else {
                // Check if we have enough room in byte_buf
                if (byte_buf_offset + read_result > byte_buf_size) {
                    // Make it 2x as big
                    byte_buf_size *= 2;
                    byte_buf = (uint8_t*) realloc(byte_buf, byte_buf_size);
                }

                // Copy readbuf into byte_buf
                memcpy(byte_buf + byte_buf_offset, readbuf, read_result);
                byte_buf_offset += read_result;
            }
        }

        // log it out
        printf("Got bytes: ");
        for (int i = 0; i < byte_buf_offset; i++) {
            printf("%u ", byte_buf[i]);
        }
        printf("\n");

        // Finished reading. Write it back
        ssize_t bytes_written = 0;
        while (bytes_written < byte_buf_offset) {
            ssize_t write_result = write(socket, byte_buf, byte_buf_offset);
            if (write_result == -1) {
                perror("error writing");
                break;
            }

            bytes_written += write_result;
        }
        printf("Wrote back %zu bytes\n", bytes_written);

        // Close socket
        int close_result = close(socket);
        if (close_result == -1) {
            perror("close error");
        }
    }

    free(byte_buf);
    close(server_socket);

    return 0;
}
