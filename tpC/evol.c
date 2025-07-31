//
// Created by diogo on 11/12/2023.
//
/*Metodo Evolutivo*/
#include "evol.h"
#include "utils_evol.h"
void tournament(pchrom pop, struct info d, pchrom parents)
{
    int i, x1, x2;

    // Realiza popsize torneios
    for(i=0; i<d.popsize;i++)
    {
        x1 = random_l_h(0, d.popsize-1);
        do
            x2 = random_l_h(0, d.popsize-1);
        while(x1==x2);
        if(pop[x1].fitness > pop[x2].fitness)		// Problema de maximizacao
            parents[i]=pop[x1];
        else
            parents[i]=pop[x2];
    }
}

void genetic_operators(pchrom parents, struct info d, pchrom offspring)
{   // Recombinação com um ponto de corte
    crossover(parents, d, offspring);
    // Mutação binária
    mutation(offspring, d);
}

// Preenche o vetor descendentes com o resultado das operações de recombinação
// Parâmetros de entrada: estrutura com os pais (parents), estrutura com parâmetros (d), estrutura que guardará os descendentes (offspring)
void crossover(pchrom parents, struct info d, pchrom offspring)
{   int i, j, point;

    for (i=0; i<d.popsize; i+=2)
    {
        if (rand_01() < d.pr)
        {
            point = random_l_h(0, d.numGenes-1);
            for (j=0; j<point; j++)
            {
                offspring[i].p[j] = parents[i].p[j];
                offspring[i+1].p[j] = parents[i+1].p[j];}
            for (j=point; j<d.numGenes; j++)
            {
                offspring[i].p[j]= parents[i+1].p[j];
                offspring[i+1].p[j] = parents[i].p[j];}
        }
        else
        {
            offspring[i] = parents[i];
            offspring[i+1] = parents[i+1];}
    }
}

void crossover_uniforme(pchrom parents, struct info d, pchrom offspring)
{
    int i, j;

    for(i = 0; i < d.popsize; i+=2)
    {
        offspring[i] = parents[i];
        offspring[i+1] = parents[i+1];

        for(j = 0; j < d.numGenes; j++)
        {
            if(parents[i].p[j] != parents[i+1].p[j])
            {
                if(rand_01() < d.pr)
                {
                    offspring[i].p[j] = parents[i+1].p[j];
                    offspring[i+1].p[j] = parents[i].p[j];
                }
            }
        }
    }
}

// Mutação binária com vários pontos de mutação
// Parâmetros de entrada: estrutura com os descendentes (offspring) e estrutura com parâmetros (d)
void mutation(pchrom offspring, struct info d)
{   int i, j;

    for (i=0; i<d.popsize; i++)
        for (j=0; j<d.numGenes; j++)
            if (rand_01() < d.pm)
                offspring[i].p[j] = !(offspring[i].p[j]);
}

void mutation_trade(pchrom offstring, struct  info d)
{
    int i,j;

    for(i = 0; i < d.popsize; i++)
    {
        for(j = 0; j < d.numGenes; j++)
        {
            if(rand_01() < d.pm)
            {
                int v1;
                int v2;

                do {
                    int index = random_l_h(0, d.numGenes - 1);
                    if (offstring[i].p[index] == 1) {
                        v1 = index;
                        break;
                    }
                } while (1);

                do {
                    int index = random_l_h(0, d.numGenes - 1);
                    if (offstring[i].p[index] == 0) {
                        v2 = index;
                        break;
                    }
                } while (1);
                offstring[i].p[v1] = 0;
                offstring[i].p[v2] = 1;
                }
            }
        }
}
