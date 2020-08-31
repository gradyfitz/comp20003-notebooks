#include "stack.h"
#include <stdio.h>
#include <stdlib.h>

#define SIZE 7

int main(int argc, char **argv){
    int i;
    int current;
    struct stack *stack1 = makeStack();
    struct stack *stack2;
    
    if(empty(stack1)){
        printf("Stack 1 created and empty.\n");
    } else {
        printf("ERROR: Stack 1 not empty when created!\n");
    }
    
    printf("Adding 1 to stack 1.\n");
    push(stack1, 1);
    
    printf("Taking top item from stack 1.\n");
    printf("Top item on stack 1 was: %d.\n",pop(stack1));
    
    printf("Adding numbers %d to %d to stack 1.\n",1,SIZE);
    for(i = 0; i < SIZE; i++){
        push(stack1, i + 1);
    }
    
    if(empty(stack1)){
        printf("ERROR: Stack 1 empty.\n");
    } else {
        printf("Stack 1 not empty after items added.\n");
    }
    
    stack2 = makeStack();
    if(empty(stack2)){
        printf("Stack 2 created and empty.\n");
    } else {
        printf("ERROR: Stack 2 not empty when created!\n");
    }
    
    printf("Taking items from stack 1 and adding them to stack 2.\n");
    printf("Stack 1: ");
    for(i = 0; i < SIZE; i++){
        current = pop(stack1);
        printf("%d",current);
        /* Intercalate commas */
        if(i != (SIZE - 1)){
            printf(", ");
        }
        
        push(stack2, current);
    }
    printf("\n");
    
    if(empty(stack1)){
        printf("Stack 1 emptied.\n");
    } else {
        printf("ERROR: Stack 1 not empty when all items removed!\n");
    }
    
    if(empty(stack2)){
        printf("ERROR: Stack 2 erroneously empty after items being added.\n");
    }
    
    printf("Taking items from stack 2 and printing them.\n");
    printf("Stack 2: ");
    for(i = 0; i < SIZE; i++){
        current = pop(stack2);
        printf("%d",current);
        /* Intercalate commas */
        if(i != (SIZE - 1)){
            printf(", ");
        }
    }
    printf("\n");
    
    if(empty(stack2)){
        printf("Stack 2 emptied.\n");
    } else {
        printf("ERROR: Stack 2 not empty when all items removed!\n");
    }
    
    freeStack(&stack1);
    freeStack(&stack2);
    
    return 0;
}
