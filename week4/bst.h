struct bst;

/*
    The function you are to write. Takes a parent pointer (null for the root),
    and returns the tree with the child in the right position. Returns the
    item in a new tree with null left/right pointers.
*/
struct bst *bstInsert(struct bst *parent, int data);

/* Draws the tree. You will need to change this if your bst uses different names. */
/* You needn't understand how this works, but you're welcome to try. */
void drawTree(struct bst *parent);

/*
    Frees the given tree, doing nothing on an empty tree, freeing child trees
    (recursively) first, then freeing the passed parent.
*/
void freeTree(struct bst *parent);
