#ifndef I_I_A_2_FUN_EVOL_H
#define I_I_A_2_FUN_EVOL_H
#include "evol.h"
void evaluate(pchrom pop, struct info d, int **mat);
int eval_individual_penalizado(int sol[], struct info d, int **mat, int *v);
int eval_individual_rep(int sol[], struct info d, int **mat, int *v);
int blindrepara(int *sol, int **mat, struct info d);
int semligcao(int *sol, int **mat, int numGenes);
#endif //I_I_A_2_FUN_EVOL_H
