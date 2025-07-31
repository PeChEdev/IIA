cmake_minimum_required(VERSION 3.26)
project(i_i_a_2 C)

set(CMAKE_C_STANDARD 99)

add_executable(i_i_a_2 main.c
        algoritmos.c
        algoritmos.h
        funcao.c
        utils.c
        evol.h
        utils_evol.h
        fun_evol.h
        evol.c
        utils_evol.c
        fun_evol.c
        hibrido.c
        hibrido.h)
