#include <stdio.h>
#include <stdlib.h>
/* You may also include additional libraries, but I don't think you will need to. */

void changeImportant(int newVal);

int main(int argc, char **argv){
    int important = 5;
    printf("Value of important[%p] before: %d\n", &important, important);
    changeImportant(7);
    printf("Value of important[%p] after: %d\n", &important, important);
    return 0;
}

void changeImportant(int newVal){
    /* ---- Your jurisdiction starts here. ---- */
    /* 
        Change the value of important in main to the newVal.
    */
    /* ---- Your jurisdiction ends here. ---- */
}
