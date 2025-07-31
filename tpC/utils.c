#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#include "utils.h"
#include "algoritmos.h"

int** init_dados(char *nome, int *n, int *k)
{
    FILE *f;
    int **p;
    int lin, col, custo;
    int lig;
    char c;
    char str[100];

    f=fopen(nome, "r");
        if(!f)
        {
        printf("Erro no acesso ao ficheiro dos dados\n");
        exit(1);}

    fscanf(f, "%c %d", &c, k);
    printf("%d ", *k);


    while(strcmp(str,"edge")){
        fscanf(f,"%s",str);}

    fscanf(f, "%d %d", n, &lig);
    printf("%d %d\n", *n, lig);

    p = malloc(sizeof(int*)*(*n));
    if(!p)
    {
        printf("Erro na alocacao de memoria\n");
        exit(1);}

    for(int i=0; i<*n; i++)
        {
        p[i] = malloc(sizeof(int)*(*n));
        if(p[i] == NULL)
        {
            printf("Erro na alocacao de memoria\n");
            exit(1);}
        for(int j=0; j<*n; j++)
            p[i][j] = 0;}

    for(int i = 0; i<lig; i++)
        {
        fscanf(f," e %d %d %d",&lin, &col, &custo );
        p[lin-1][col-1] = custo;
        p[col-1][lin-1] = custo;}

    fclose(f);
    return p;}

void gera_sol_inicial(int *sol, int v, int k)
{   int i, x;

    for(i=0; i<v; i++)
        sol[i]=0;

    for(i=0; i<k; i++)
        {
        do
            x = random_l_h(0, v-1);
        while(sol[x] != 0);
        sol[x]=1;}
}

void escreve_ficheiro(int *sol, int vert, FILE *f){

    fprintf(f,"Conjunto Solucao: ");
    for(int i=0; i<vert; i++)
        if(sol[i] == 1)
            fprintf(f, "%d ", i+1);}

void substitui(int a[], int b[], int n)
{   int i;
    for(i=0; i<n; i++)
        a[i]=b[i];}

void init_rand()
{srand((unsigned)time(NULL));}

int random_l_h(int min, int max)
{return min + rand() % (max-min+1);}

float rand_01()
{return ((float)rand())/RAND_MAX;}
