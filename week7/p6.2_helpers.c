/*
    Some obvious code which is split out to keep the program as small as possible.
*/
void printArray(int *array, int arrayLength){
    int i;
    for(i = 0; i < arrayLength; i++){
        if(i > 0){
            printf(" ");
        }
        printf("%d",array[i]);
    }
    printf("\n");
}

void swap(int index1, int index2, int *array);
