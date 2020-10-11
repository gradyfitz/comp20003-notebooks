/* #include "digraph.h" */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

struct digraph{
    int lowIndex;
    int highIndex;
    struct weightedEdge **adjacencyList;
    int allocated;
    int used;
};

struct digraph *newDigraph(){
    struct digraph *retDigraph = (struct digraph *) malloc(sizeof(struct digraph));
    assert(retDigraph);
    
    /* Don't initialise until we have at least one edge so we don't go over-allocate. */
    retDigraph->adjacencyList = NULL;
    retDigraph->allocated = 0;
    retDigraph->used = 0;
    
    return retDigraph;
}

void addEdge(struct digraph *graph, int source, int destination, int weight, int capacity){
    int initialSize;
    int newLow;
    int newHigh;
    int i;
    struct weightedEdge *newEdge;
    if(! graph->allocated){
        initialSize = source - destination;
        if(initialSize < 0){
            initialSize = -initialSize;
        }
        /* Assume initialSize positive now, theoretically it may not be, but
            we needn't worry about that for now. */
        initialSize = initialSize + 1;
        graph->adjacencyList = (struct weightedEdge **) 
            malloc(sizeof(struct weightedEdge *)*initialSize);
        assert(graph->adjacencyList);
        graph->allocated = initialSize;
        /* Initialise edge list. */
        for(i = 0; i < initialSize; i++){
            (graph->adjacencyList)[i] = NULL;
        }
        /* Initialise low and high indices. */
        if(source < destination){
            graph->lowIndex = source;
            graph->highIndex = destination;
        } else {
            graph->lowIndex = destination;
            graph->highIndex = source;
        }
        graph->used = initialSize;
    } else {
        /* Ensure we have space for the new edge */
        if(graph->lowIndex > source || graph->lowIndex > destination){
            if(source < destination){
                newLow = source;
            } else {
                newLow = destination;
            }
        } else {
            newLow = graph->lowIndex;
        }
        if(graph->highIndex < source || graph->highIndex < destination){
            if(source > destination){
                newHigh = source;
            } else {
                newHigh = destination;
            }
        } else {
            newHigh = graph->highIndex;
        }
        if(newHigh != graph->highIndex || newLow != graph->lowIndex){
            /* Wasn't space for edge in current adjacency graph, 
                realloc space, move all edge lists along. */
            graph->allocated = newHigh - newLow + 1;
            graph->adjacencyList = (struct weightedEdge **) 
                realloc(graph->adjacencyList, sizeof(struct weightedEdge *)*graph->allocated);
            assert(graph->adjacencyList);
            /* Move from end of list to start of list to ensure none are overwritten. */
            for(i = graph->highIndex - graph->lowIndex; i >= 0; i--){
                graph->adjacencyList[i - newLow + graph->lowIndex] = graph->adjacencyList[i];
            }
            /* Fill in new low values. */
            for(i = 0; i < (graph->lowIndex - newLow); i++){
                graph->adjacencyList[i] = NULL;
            }
            /* Fill in new high values. */
            for(i = graph->highIndex - newLow + 1; i < (newHigh - newLow + 1); i++){
                graph->adjacencyList[i] = NULL;
            }
            
            graph->lowIndex = newLow;
            graph->highIndex = newHigh;
            graph->used = graph->allocated;
        }
    }
    
    /* Add the edge to the relevant place [prepend the list]. */
    newEdge = (struct weightedEdge *) malloc(sizeof(struct weightedEdge));
    assert(newEdge);
    newEdge->destIndex = destination;
    newEdge->weight = weight;
    newEdge->next = graph->adjacencyList[source - graph->lowIndex];
    newEdge->capacity = capacity;
    graph->adjacencyList[source - graph->lowIndex] = newEdge;
}

int *getNodes(struct digraph *graph, int *size){
    /* A list of active edges, edges will be flipped on as traversed, 
        the bits will then be counted and the exact amount of space needed
        will be allocated. */
    char *bitmask;
    int i, j;
    int count;
    int *returnList;
    struct weightedEdge *current;
    bitmask = (char *) malloc(sizeof(char)*graph->used);
    assert(bitmask);
    for(i = 0; i < graph->used; i++){
        /* This conversion is for clarity, '\0' would have done the trick
            too. */
        bitmask[i] = (char) 0;
    }
    /* Fill in all the bits from the adjacency list. */
    for(i = 0; i < graph->used; i++){
        if(graph->adjacencyList[i]){
            bitmask[i] = (char) 1;
            current = graph->adjacencyList[i];
            while(current){
                bitmask[current->destIndex - graph->lowIndex] = (char) 1;
                current = current->next;
            }
        }
    }
    
    count = 0;
    for(i = 0; i < graph->used; i++){
        if(bitmask[i]){
            count++;
        }
    }
    
    returnList = (int *) malloc(sizeof(int)*(count + 1));
    
    j = 0;
    for(i = 0; i < graph->used; i++){
        if(bitmask[i]){
            returnList[j] = i + graph->lowIndex;
            j++;
        }
    }
    /* Add sentinel value. */
    returnList[j] = graph->lowIndex - 1;
    
    if(size){
        *size = j;
    }
    
    free(bitmask);
    
    return returnList;
}

struct weightedEdge *getAdjacent(struct digraph *graph, int *nodeList, int sourceIndex){
    /* Find length of provided node list. */
    int length = 0;
    while(nodeList[length] >= graph->lowIndex){
        length++;
    }
    
    struct weightedEdge *current = NULL;
    struct weightedEdge *returnList = NULL;
    struct weightedEdge *currentGraph = NULL;
    
    currentGraph = graph->adjacencyList[nodeList[sourceIndex] - graph->lowIndex];
    if(currentGraph){
        while(currentGraph){
            /* Move current to its next value. */
            if(! current){
                returnList = (struct weightedEdge *) malloc(sizeof(struct weightedEdge));
                assert(returnList);
                current = returnList;
            } else {
                current->next = (struct weightedEdge *) malloc(sizeof(struct weightedEdge));
                assert(current->next);
                current = current->next;
            }
            /* Append modified value. */
            current->next = NULL;
            current->weight = currentGraph->weight;
            current->destIndex = convertIndex(nodeList, currentGraph->destIndex);
            currentGraph = currentGraph->next;
        }
        return returnList;
    } else {
        /* No edges for source index. */
        return NULL;
    }
}

struct weightedEdge *getAdjReference(struct digraph *graph, int sourceIndex){
    if(!graph || sourceIndex > graph->highIndex || sourceIndex < graph->lowIndex){
        return NULL;
    }
    return (graph->adjacencyList)[sourceIndex - graph->lowIndex];
}

int convertIndex(int *list, int originalIndex){
    int i = 0;
    while(list[i] != originalIndex){
        i++;
    }
    return i;
}

void freeDigraph(struct digraph *graph){
    int i;
    struct weightedEdge *current;
    struct weightedEdge *next;
    if(!graph){
        return;
    }
    for(i = 0; i < graph->allocated; i++){
        if(graph->adjacencyList[i]){
            current = graph->adjacencyList[i];
            graph->adjacencyList[i] = NULL;
            while(current){
                next = current->next;
                free(current);
                current = next;
            }
        }
    }
    if(graph->allocated > 0){
        free(graph->adjacencyList);
    }
    free(graph);
}