#define _CRT_SECURE_NO_WARNINGS 1
#include <stdlib.h>
#include "fun_evol.h"
#include "utils_evol.h"
int eval_individual_penalizado(int sol[], struct info d, int **mat, int *v) {
    int i, j;
    int sum = 0, flag = 0;
    int vertice = 0;
    *v = 1;
    for (i = 0; i < d.numGenes; i++) {
        flag = 0;
        if (sol[i] == 1) {
            vertice++;
            for (j = 0; j < d.numGenes; j++) {
                if (sol[j] == 1 && mat[i][j] != 0 && i != j) {
                    sum += mat[i][j];
                    flag += 1;
                }
            }
            if (flag == 0) {
                *v = 0;}
        }
    }
    if (vertice != d.capacity) {*v = 0;}
    if (*v == 0) {return 999;} else {return sum / 2;}
}

int eval_individual_rep(int sol[], struct info d, int **mat, int *v)
{   int i, j, valido;
    int sum = 0, flag = 0;
    int vertice = 0;
    *v = 1;
    for(i = 0; i < d.numGenes; i++)
    {
        flag = 0;
        if(sol[i] == 1)
        {
            vertice++;
            for(j = 0; j < d.numGenes; j++)
            {
                if(sol[j] == 1 && mat[i][j] != 0 && i != j)
                {
                    sum += mat[i][j];
                    flag += 1;}
            }
            if(flag == 0)
            {
                *v = 0;
                break;}
        }
        if(*v != 0)
        {
            valido = 0;
            do {
                valido = blindrepara(sol,mat,d);} while (valido == 0);

            for(i = 0; i < d.numGenes; i++)
            {
                if(sol[i] == 1)
                {
                    for(j = 0; j < d.numGenes; j++)
                    {
                        if(sol[j] == 1 && mat[i][j] != 0 && i != j)
                        {sum += mat[i][j];}
                    }
                }
            }
            *v = 1;
            return sum / 2;}
        else
        {return sum / 2;}
    }
}

void evaluate(pchrom pop, struct info d, int **mat)
{   int i;
    for (i=0; i<d.popsize; i++)
        pop[i].fitness = eval_individual_rep(pop[i].p, d, mat, &pop[i].valido);}

int VerticesCont(int *sol, int numGenes, int k) {
    int i, conta = 0;
    /*Percorrer o array da solução*/
    for (i = 0; i < numGenes; i++) {
        /*Verifica se o valor do array atual é igual a 1*/
        if (sol[i] == 1) {conta++;}
    }
    return conta;}

int ArestasCont(int *sol, int **mat, int numGenes) {
    int i, j, conta = 0;
    int flag;
    /*Percorrer os Vertices*/
    for (i = 0; i < numGenes; i++) {
        flag = 0;
        /*Verificar se as Arestas estão na Solução*/
        if (sol[i] == 1) {
            for (j = 0; j < numGenes; j++) {
                if (sol[j] == 1 && mat[i][j] != 0 && i != j) {
                    /*Verificar se a Aresta é valida*/
                    flag = 1;
                }
            }
            if (flag == 0)
            {return 0;}
        }
    }
    return 1;}

int NoLig(int *sol, int **mat, int numGenes) {
    int i, j, conta = 0;
    int flag;
    while(1)
    {
        i = random_l_h(0, numGenes - 1);
        /*Verificar se as Vertice estão na Solução*/
        if (sol[i] == 1) {
            flag = 0;
            for (j = 0; j < numGenes; j++) {
                if (sol[j] == 1 && mat[i][j] != 0 && i != j) {
                    /*Se encontrar ligacao*/
                    flag = 1;
                }
            }
            if (flag == 0) {return i;}

        }
    }
    return -1;}

int semligcao(int *sol, int **mat, int numGenes) {
    int i, j, conta = 0;
    //Encontra um vertice com sem ligacao
    while(1)
    {
        i = random_l_h(0, numGenes - 1);
        int flag = 0;
        /*Verifica se existe na soluçao*/
        if (sol[i] == 0) {
            for (j = 0; j < numGenes; j++) {
                if (sol[j] == 1 && mat[i][j] != 0 && i != j) {return i;}
            }
        }
    }
    return -1;}

/*Reparacao Valor Random*/
int blindrepara(int *sol, int **mat, struct info d) {

    if (VerticesCont(sol, d.numGenes, d.capacity) == d.capacity) {
        if (ArestasCont(sol, mat, d.numGenes) == 1) {
            //getchar();
            return 1;
        } else {
            // troca um vertice de 0 para 1 e um outro de 1 para 0
            int v1, v2;
            do {
                v1 = NoLig(sol, mat, d.numGenes);
                if (v1 == -1)
                    exit(1);
            } while (sol[v1] == 0);
            do {
                v2 = semligcao(sol, mat, d.numGenes);
                if (v2 == -1)
                    exit(1);
            } while (sol[v2] == 1);
            sol[v1] = 0;
            sol[v2] = 1;
            return 0;}
    } else if (VerticesCont(sol, d.numGenes, d.capacity) < d.capacity) {
        // troca um vertice de 0 para 1
        int v1;
        do {
            v1 = random_l_h(0, d.numGenes - 1);
        } while (sol[v1] == 1);
        sol[v1] = 1;
        return 0;
    } else {
        // troca um vertice de 1 para 0
        int v1;
        do {
            v1 = random_l_h(0, d.numGenes - 1);
        } while (sol[v1] == 0);
        sol[v1] = 0;
        return 0;}
}
