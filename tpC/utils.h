#ifndef I_I_A_2_UTILS_H
#define I_I_A_2_UTILS_H
#include <stdio.h>
#include "algoritmos.h"
void escreve_ficheiro(int *sol, int vert, FILE *f);
int** init_dados(char *nome, int *n, int *k);
void gera_sol_inicial(int *sol, int v, int k);
void substitui(int a[], int b[], int n);
void init_rand();
int random_l_h(int min, int max);
float rand_01();
#endif //I_I_A_2_UTILS_H
