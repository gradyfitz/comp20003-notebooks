#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "hashT.h"

#define TABLESIZE 13
#define INPUTSIZE 7

int *hashFunc(void *val){
    int *retVal = (int *) malloc(sizeof(int));
    assert(retVal);

    *retVal = *((int *)val) % TABLESIZE;

    printf("Hashing %d: %d\n",*((int *)val), *retVal);

    return retVal;
}

void print(void *val){
    if(val){
        printf("%d",*((int *) val));
    }
}

int main(int argc, char **argv){
    
    int inputs[INPUTSIZE] = {14, 30, 17, 55, 31, 29, 16};
    
    struct hashTable *DH5Table;
    struct hashTable *LPTable;
    int i;
    
    LPTable = create(TABLESIZE, &hashFunc, &insertLP, &print);
    printf("Created Linear Probing hash table of size 13\n");
    printTable(LPTable);
    
    for(i = 0; i < INPUTSIZE; i++){
        printf("Inserting %d into Linear Probing hash table\n",inputs[i]);
        insert(LPTable, &(inputs[i]));
        printTable(LPTable);
    }
    printf("Finished inserting items into Linear Probing hash table\n\n");
    
    DH5Table = create(TABLESIZE, &hashFunc, &insertDH5, &print);
    printf("Created Double Hashing table of size 13 using hash2(x) = (key %% 5) + 1\n");
    printTable(DH5Table);
    
    for(i = 0; i < INPUTSIZE; i++){
        printf("Inserting %d into Double Hashing hash table\n",inputs[i]);
        insert(DH5Table, &(inputs[i]));
        printTable(DH5Table);
    }
    printf("Finished inserting items into Double Hashing hash table\n");
    
    freeTable(LPTable);
    freeTable(DH5Table);
    
    return 0;
}
