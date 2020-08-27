#include <stdio.h>
#include <stdlib.h>
#include "llqueue.h"
#include <assert.h>

struct llqueue {
    struct llitem *first;
    struct llitem *last;
};

struct llitem {
    struct llitem *next;
    void *item;
};

struct llqueue *newQueue(){
    struct llqueue *ret = (struct llqueue *) malloc(sizeof(struct llqueue));
    assert(ret);

    ret->first = NULL;
    ret->last = NULL;
    return ret;
}



/* Adds the given item to the queue, allocating if needed. */
void queue(struct llqueue **queue, void *item){
    if(!queue){
        return;
    }
    if(!*queue){
        *queue = newQueue();
    }
    struct llitem *newItem = (struct llitem *) malloc(sizeof(struct llitem));
    assert(newItem);
    newItem->next = NULL;
    newItem->item = item;
    if(!(*queue)->first){
        (*queue)->first = newItem;
    } else {
        (*queue)->last->next = newItem;
    }
    (*queue)->last = newItem;
}

void *dequeue(struct llqueue *queue){
    if(!queue || !queue->first){
        fprintf(stderr, "Failed to take item from queue, queue empty.\n");
    }
    void *retItem = queue->first->item;

    struct llitem *newFirst = queue->first->next;

    if(queue->first->next == NULL){
        queue->last = NULL;
    }

    free(queue->first);

    queue->first = newFirst;

    return retItem;
}

int empty(struct llqueue *queue){
    if(! queue || ! queue->first){
        return 1;
    } else {
        return 0;
    }
}
