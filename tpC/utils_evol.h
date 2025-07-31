#ifndef I_I_A_2_UTILS_EVOL_H
#define I_I_A_2_UTILS_EVOL_H
#include "utils_evol.h"
int** init_data(char *nome, int *n, int *k);

pchrom init_pop(struct info d);

chrom get_best(pchrom pop, struct info d, chrom best);

void write_best(chrom x, struct info d);

void init_rand();

int random_l_h(int min, int max);

float rand_01();

int flip();

#endif //I_I_A_2_UTILS_EVOL_H
