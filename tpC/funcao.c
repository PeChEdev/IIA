#include "funcao.h"
#include "utils.h"
#include "algoritmos.h"
int calcula_fit(int a[], int **mat, int vert)
{   int i, j, teste, sum = 0;

    for(i = 0; i<vert; i++) {
        teste = 0;
        if (a[i] == 1)
        {
            for (j = 0; j < vert; j++)
            {
                if (a[j] == 1 && mat[i][j] != 0) {
                    sum += mat[i][j];
                    teste = 1;}
            }
                if (teste == 0) {

                    return 999999999;}
        }
    }
    return sum/2;}






