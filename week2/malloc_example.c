// Try these out with Valgrind
// Compile with
//   gcc -g -Wall malloc_example.c -o malloc_example
//
// Run in Valgrind with
//   valgrind --tool=memcheck malloc_example
//
// Errors to try:
// - Comment out the malloc line (and the assert),
// - Comment out the free line,
// - Comment out the line where you set values[0],
// - Set a value for values[2],
// - Change the value of NUMBEROFINTS to 1.

#include <stdio.h>
// Include the header we need for malloc.
#include <stdlib.h>
// malloc will return NULL if it fails, asserts are a quick way to check success.
#include <assert.h>

#define NUMBEROFINTS 2

int main(int argc, char **argv){
    // We declare space to store a pointer of type int.
    // The value NULL is just an alias for 0 (of pointer type).
    int *values = NULL;

    // Here we allocate space for two integers. The result is a generic pointer,
    // so we also set the type to a pointer to integers.
    values = (int *) malloc(sizeof(int) * NUMBEROFINTS);
    // Check memory was successfully allocated
    assert(values != NULL);

    // Set each of the integers.
    values[0] = 10;
    values[1] = 32;

    // Print the values out.
    printf("%d %d\n", values[0], values[1]);

    // free the malloced memory.
    free(values);

    return 0;
}
