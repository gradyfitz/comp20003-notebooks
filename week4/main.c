#include <stdio.h>
#include <stdlib.h>
#include "bst.h"

int main(int argc, char **argv){
    int inputData;
    struct bst *bst = NULL;
    while(scanf("%d",&inputData) > 0){
        bst = bstInsert(bst, inputData);
    }

    drawTree(bst);

    freeTree(bst);

    return 0;
}
