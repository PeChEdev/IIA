#include "hibrido.h"
#include "utils_evol.h"
#include "algoritmos.h"
#include "fun_evol.h"
#define Ngeneration_h 100
#define TrocaVertice 1.0
void gera_vizinho_hibrido(int sol[],int solViz[],int **mat,int nGenes)
{
    int i;
    //copia a solucao para a vizinha
    for(i=0;i<nGenes;i++) {
        solViz[i] = sol[i];
        if (rand_01() < TrocaVertice) {
            i = random_l_h(0, nGenes - 1);
            solViz[i] =! solViz[i];
        }
        else {
            for (i = 0; i < nGenes; i++) {
                gera_vizinho(sol, solViz, nGenes);
            }
        }
    }
}
void recristalizacao_hibrido(pchrom pop,struct info d,int **mat){
    int i,j;
    chrom vizinho;
    for(i=0;i<d.popsize;i++)
    {
        for(j=0;j<Ngeneration_h;j++)
        {
            gera_vizinho_hibrido(pop[i].p,vizinho.p,mat,d.numGenes);
            vizinho.fitness=eval_individual_rep(vizinho.p,d,mat,&vizinho.valido);
            if(vizinho.fitness < pop[i].fitness)
                pop[i]=vizinho;
        }
    }

}