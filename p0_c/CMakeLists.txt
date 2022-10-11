cmake_minimum_required(VERSION 3.17)
project(p0_c C)

set(CMAKE_C_STANDARD 99)

add_executable(p0_c main.c)

# Enable all warnings
if(MSVC)
    target_compile_options(p0_c PRIVATE /W4 /WX)
else()
    target_compile_options(p0_c PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()