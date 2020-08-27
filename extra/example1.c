//% stdin: "input line 1"
//% stdin: "input line 2"
//% stdin: "input line 3"
//% stdin: "4th input line"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#define MAXSTRINGSIZE 15

struct node {
    char *string;
    struct node *next;
};

struct node *new_node(){
    struct node *new_node = (struct node *) malloc(sizeof(struct node));
    new_node->string = (char *) malloc(sizeof(char) * MAXSTRINGSIZE);
    assert(new_node->string);
    return new_node;
}

void store_string(struct node *node, char *buffer){
    node->string = buffer;
}

int main(int argc, char **argv){
    char *buffer = (char *) malloc(sizeof(char) * MAXSTRINGSIZE);
    assert(buffer);
    struct node *head = new_node();
    while(scanf("%[^\n]\n", buffer) == 1){
        printf("%s\n", buffer);
        store_string(head, buffer);
    }
    printf("Head string: %s\n", head->string);
    printf("Next string: %s\n", head->next->string);
    printf("Next next string: %s\n", head->next->next->string);
    printf("Last string: %s\n", head->next->next->next->string);
    
    free(head->string);
    free(head);
    return 0;
}
