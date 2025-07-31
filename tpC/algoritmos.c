#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "utils.h"
#include "funcao.h"
#include "algoritmos.h"
void gera_vizinho(int a[], int b[], int n)
{   int i, p1, p2;

    for(i=0; i<n; i++)
        b[i]=a[i];
    do
        p1=random_l_h(0, n-1);
    while(b[p1] != 0);
    do
        p2=random_l_h(0, n-1);
    while(b[p2] != 1);
    b[p1] = 1;
    b[p2] = 0;}

void gera_vizinho2(int a[], int b[], int n)
{
    int i, p1, p2, p3, p4;

    for(i=0; i<n; i++)
        b[i]=a[i];
    do
        p1=random_l_h(0, n-1);
    while(b[p1] != 0);
    do
        p2=random_l_h(0, n-1);
    while(b[p2] != 1);
    do
        p3=random_l_h(0, n-1);
    while(b[p3] != 0 || p3 == p1);
    do
        p4=random_l_h(0, n-1);
    while(b[p4] != 1 || p4 == p2);

    b[p1] = 1;
    b[p2] = 0;
    b[p3] = 1;
    b[p4] = 0;}


int recristalizacao(int *sol, int **mat, int vert)
{   int *nova_sol, custo, custo_viz;
    double t, r;
    nova_sol = malloc(sizeof(int)*vert);

    if(nova_sol == NULL)
        {
        printf("Erro na alocacao de memoria");
        exit(1);}

    custo = calcula_fit(sol, mat, vert);
    int k = 5;
    t = tmax;

    while(t > tmin)
    {
        for(int i = 0; i<k; i++)
        {
            gera_vizinho(sol, nova_sol, vert);
            custo_viz = calcula_fit(nova_sol, mat, vert);

            if(custo_viz <= custo)
                {
                substitui(sol, nova_sol, vert);
                custo = custo_viz;}
            else
                {
                r = rand_01();
                    if(r < exp(-(custo_viz-custo)/t))
                    {
                    substitui(sol, nova_sol, vert);
                    custo = custo_viz;}
                }
        }
        t *= fa;}
    free(nova_sol);
    return custo;}