struct stack;

/* Returns a pointer to an empty stack */
struct stack *makeStack();

/* Adds an item to the top of the stack. */
void push(struct stack *stack, int item);

/* Returns the top item from the stack. */
int pop(struct stack *stack);

/* Checks whether the stack is empty. */
int empty(struct stack *stack);

/* Frees the stack and sets the pointer at the location
    provided to NULL. */
void freeStack(struct stack **stack);
