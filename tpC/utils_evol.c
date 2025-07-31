#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "evol.h"
#include "utils_evol.h"
#include "utils.h"
// Leitura dos parâmetros e dos dados do problema
// Parâmetros de entrada: Nome do ficheiro e matriz a preencher com os dados dos objectos (peso e valor)
// Parâmetros de saída: Devolve a estrutura com os parâmetros
int** init_data(char *nome, int *n, int *k)
{   FILE *f;
    int **p;
    int lin, col, custo;
    int lig;
    char str[100];
    char c;

    f=fopen(nome, "r");
    if(!f)
    {
        printf("Erro no acesso ao ficheiro dos dados\n");
        exit(1);
    }
    // Numero de iteracoes
    fscanf(f, "%c %d", &c, k);
    // Numero de vertices
    while(strcmp(str,"edge")){
        fscanf(f,"%s",str);
    }
    fscanf(f, "%d %d", n, &lig);
    // Alocacao dinamica da matriz
    p = malloc(sizeof(int*)*(*n));
    if(!p)
    {
        printf("Erro na alocacao de memoria\n");
        exit(1);
    }
    // Inicia tudo a 0
    for(int i=0; i<*n; i++)
    {
        p[i] = malloc(sizeof(int)*(*n));
        if(p[i] == NULL)
        {
            printf("Erro na alocacao de memoria\n");
            exit(1);
        }
        for(int j=0; j<*n; j++)
            p[i][j] = 0;
    }
    // Preenche com os valores do ficheiro
    // Mesma logica do ciclo anterior
    // -1 porque os vertices começam em 1
    // Coloca o custo nas duas posições.
    for(int i = 0; i<lig; i++)
    {
        fscanf(f," e %d %d %d",&lin, &col, &custo );
        p[lin-1][col-1] = custo;
        p[col-1][lin-1] = custo;
    }
    fclose(f);
    printf("File %s read\n", nome);
    return p;}

// Simula o lançamentoint** init_data(char *nome, int *n, int *k) de uma moeda, retornando o valor 0 ou 1
int flip()
{   if ((((float)rand()) / RAND_MAX) < 0.5)
        return 0;
    else
        return 1;}

// Criacao da populacao inicial. O vector e alocado dinamicamente
// Parâmetro de entrada: Estrutura com parâmetros do problema
// Parâmetro de saída: Preenche da estrutura da população apenas o vector binário com os elementos que estão dentro ou fora da mochila
pchrom init_pop(struct info d)
{   int     i, j;
    pchrom  indiv;

    indiv = malloc(sizeof(chrom)*d.popsize);
    if (indiv==NULL)
    {
        printf("Erro na alocacao de memoria\n");
        exit(1);
    }
    for (i=0; i<d.popsize; i++)
    {
        for (j=0; j<d.numGenes; j++)
            indiv[i].p[j] = flip();}
    return indiv;}

// Actualiza a melhor solução encontrada
// Parâmetro de entrada: populacao actual (pop), estrutura com parâmetros (d) e a melhor solucao encontrada até a geraçãoo imediatamente anterior (best)
// Parâmetro de saída: a melhor solucao encontrada até a geração actual
chrom get_best(pchrom pop, struct info d, chrom best)
{   int i;

    for (i=0; i<d.popsize; i++)
    {
        if(best.valido == 0)
        {
            if(pop[i].valido == 1)
                best = pop[i];
            else if(pop[i].fitness < best.fitness)
                best = pop[i];
        }
        else
        {
            if(pop[i].valido == 1 && pop[i].fitness < best.fitness)
                best=pop[i];
        }
    }
    return best;}


// Escreve uma solução na consola
// Parâmetro de entrada: populacao actual (pop) e estrutura com parâmetros (d)
void write_best(chrom x, struct info d)
{printf("\nBest individual: %4.1f\n", x.fitness);}