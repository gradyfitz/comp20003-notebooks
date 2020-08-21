#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "llqueue.h"
#include "bst.h"

struct bst {
    struct bst *left;
    struct bst *right;
    int data;
};

/*
    The function you are to write. Takes a parent pointer (null for the root),
    and returns the tree with the child in the right position. Returns the
    item in a new tree with null left/right pointers.
*/
struct bst *bstInsert(struct bst *parent, int data){
    /* Write this function. */






}

void freeTree(struct bst *parent){
    if(! parent){
        return;
    }
    /* Fill in function according to function description. */
}

/* Calculate the number of spaces which need to appear before and after the
    data point at a given depth to allow a single character to occur in all
    children below it. */
int spacesAtDepth(int depth);

/* Calculate the depth to the deepest child of a given node. */
int countDepth(struct bst *parent);

/* Draws the tree. You will need to change this if your bst uses different names. */
/* You needn't understand how this works, but you're welcome to try. */
void drawTree(struct bst *parent){
    int i;
    if(!parent){
        /* Done, no tree to print. */
        return;
    }

    struct llqueue *currentQueue = newQueue();
    struct llqueue *nextQueue = newQueue();
    /* Used for swapping. */
    struct llqueue *tempQueue;
    /* Current node being processed */
    struct bst *current;

    /* The depth of the parent, used to work out where to place the value. */
    int depth = countDepth(parent);

    /* The number of spaces needed at the current level before and after each
        data value. */
    int spaces = spacesAtDepth(depth);


    /* Add the parent node to the queue. */
    queue(&currentQueue, parent);

    while(!empty(currentQueue) && depth >= 0){
        current = (struct bst *) dequeue(currentQueue);
        for(i = 0; i < spaces; i++){
            printf("  ");
        }
        if(current){
            printf("%2d",current->data);
        } else {
            printf("  ");
        }
        for(i = 0; i < spaces; i++){
            printf("  ");
        }
        /* Account for parent's space */
        printf("  ");

        /* Queue any children for next row */
        if(current && current->left){
            queue(&nextQueue, current->left);
        } else {
            /* Mark empty space so spacing stays consistent. */
            queue(&nextQueue, NULL);
        }

        if(current && current->right){
            queue(&nextQueue, current->right);
        } else {
            /* Mark empty space so spacing stays consistent. */
            queue(&nextQueue, NULL);
        }

        if(empty(currentQueue)){
            /* Start new row. */
            printf("\n");
            /* Update depth information. */
            depth--;
            spaces = spacesAtDepth(depth);

            /* Swap the new row to the current row. */
            tempQueue = currentQueue;
            currentQueue = nextQueue;
            nextQueue = tempQueue;
        }
    }
    /* If we reach depth 0, the queue may still have contents
        we must empty first. */
    while(!empty(currentQueue)){
        current = (struct bst *) dequeue(currentQueue);
    }
    if(tempQueue){
        free(nextQueue);
    }
    if(currentQueue){
        free(currentQueue);
    }
}

int countDepth(struct bst *parent){
    int leftDepth;
    int rightDepth;
    if(!parent){
        /* Here we assume a leaf node is at depth -1, other choices are possible. */
        return -1;
    }
    leftDepth = countDepth(parent->left);
    rightDepth = countDepth(parent->right);
    if(leftDepth > rightDepth){
        return leftDepth + 1;
    } else {
        return rightDepth + 1;
    }
}

int spacesAtDepth(int depth){
    int cDepth = depth;
    int result = 1;
    while(cDepth > 0){
        result = 2*result + 1;
        cDepth--;
    }
    return result;
}
