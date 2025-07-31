#include <stdio.h>
#include <stdlib.h>

#include "funcao.h"
#include "algoritmos.h"
#include "utils.h"
#include "evol.h"
#include "utils_evol.h"
#include "fun_evol.h"
#include "hibrido.h"
#include "string.h"
#define DEFAULT_RUNS 30
#define DEFAULT_ITER 10000
#define PopSize 100
#define NumGene 500
#define Mutacao 0.01
#define Repro 0.5
#define roleta 0
#define tournmanent 2

//int exec(int runs, int n, int num_iter, FILE *resultado) {
//    int vert, i, k, custo, **grafo, *sol, *best, best_custo = 0;
//    char filename[100];
//    float mbf = 0.0;
//
//    sprintf(filename, "file%d.txt", n);
//
//    fprintf(resultado, "\nFicheiro: %s\n", filename);
//
//    init_rand();
//    grafo = init_dados(filename, &vert, &k);
//
//    sol = malloc(sizeof(int) * vert);
//    best = malloc(sizeof(int) * vert);
//
//
//    if (sol == NULL || best == NULL) {
//        fprintf(stderr, "Erro na alocacao de memoria para as solucoes");
//        exit(1);}
//
//    int penalizadas = 0;
//    for (i = 0; i < runs; i++) {
//        gera_sol_inicial(sol, vert, k);
//
//        custo = recristalizacao(sol, grafo, vert);
//
//
//        if (custo <= 9999) {mbf += (float) custo;} else {penalizadas++;}
//
//        if (i == 0 || best_custo > custo) {
//            best_custo = custo;
//            substitui(best, sol, vert);}
//    }
//
//    fprintf(resultado, "Melhor solucao encontrada\n");
//
//    escreve_ficheiro(best, vert, resultado);
//    fprintf(resultado, "\nCusto final: %d\n", best_custo);
//
//    if (penalizadas == i)
//        fprintf(resultado, "MBF: Todas as solucoes sao invalidas\n");
//    else
//        fprintf(resultado, "MBF: %.2f\n", mbf / (float) (i - penalizadas));
//
//    free(grafo);
//    free(sol);
//    free(best);
//    return 0;
//}

int main(int argc, char *argv[]) {
//    FILE *resultado = fopen("resultado.txt", "w+");
//
//    for(int i = 0; i < 5; i++){exec(DEFAULT_RUNS, i+1, DEFAULT_ITER, resultado);}
//    fclose(resultado);

/*Metodo Evolutivo*/
    char nome_fich[100];
    struct info EA_param;
    EA_param.popsize = PopSize;
    EA_param.numGenerations = NumGene;
    EA_param.pm = Mutacao;
    EA_param.pr = Repro;
    EA_param.ro = roleta;
    EA_param.tsize = tournmanent;
    pchrom      pop = NULL, parents = NULL;
    chrom       best_run, best_ever;
    int         gen_actual, r, i,n, inv, **mat, runs = DEFAULT_RUNS;
    float       mbf = 0.0;
    if (argc == 3)
    {
        runs = atoi(argv[2]);
        strcpy(nome_fich, argv[1]);
    }
    else
        // Se o número de execuções do processo não for colocado nos argumentos de entrada, define-o com um valor por defeito
        if (argc == 2)
        {
            runs = DEFAULT_RUNS;
            strcpy(nome_fich, argv[1]);
        }
        // Se o nome do ficheiro de informações não for colocado nos argumentos de entrada, pede-o novamente
        else
        {
            runs = DEFAULT_RUNS;
            printf("Escreva inteiro correspondente ao ficheiro de texto: ");
            scanf( "%d", &n);
            sprintf(nome_fich, "file%d.txt", n);
        }
        if (runs <= 0)
            return 0;
        init_rand();
        mat = init_data( nome_fich, &EA_param.numGenes, &EA_param.capacity);
        for(r = 0; r <runs;r++)
        {
            printf("A iniciar..\n");
            pop = init_pop(EA_param);
            evaluate(pop, EA_param, mat);
            //Outra maneira de reparar a solucao final
            //recristalizacao_hibrido(pop,EA_param,mat);
            gen_actual = 1;
            best_run = pop[0];
            best_run = get_best(pop, EA_param, best_run);
            parents = malloc(sizeof(chrom)*EA_param.popsize);
            if (parents == NULL)
            {
                printf("Erro na alocacao de memoria\n");
                exit(1);
            }
            while(gen_actual <= EA_param.numGenerations)
            {
                tournament(pop, EA_param, parents);

                genetic_operators(parents,EA_param, pop);

                evaluate(pop, EA_param, mat);

                best_run = get_best(pop, EA_param, best_run);
                gen_actual++;
            }
            //Comentar para não usar o Hibrido
            //recristalizacao_hibrido(pop,EA_param,mat);
            for (inv=0, i=0; i<EA_param.popsize; i++)
                if (pop[i].valido == 0)
                    inv++;
            // Escreve resultados da repetição que terminou
            printf("\nRepeticao %d:", r);
            write_best(best_run, EA_param);
            //printf("\nPercentagem Invalidos: %.2f\n", 100*(float)inv/EA_param.popsize);
            mbf += best_run.fitness;
            if (r==0 || best_run.fitness > best_ever.fitness)
                best_ever = best_run;
            // Liberta a memória usada
            free(parents);
            free(pop);
        }
        printf("\n\nMBF: %.2f\n", mbf/r);
        printf("\nMelhor solucao encontrada");
        write_best(best_ever, EA_param);
        return 0;}