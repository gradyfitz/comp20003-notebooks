struct hashTable;

/* Insert the given key into the given hash table comparing the
    hash of the given key to the keys in the table already,
    placing it at the next free spot after where it should
    have otherwise been placed. If used >= size, the function 
    returns, doing nothing. */
void insertLP(struct hashTable *table, int *key, void *value);

/* Calculates the interval of the given key using the equation
    (key % 5) + 1 and then calls insertDH with this value. */
void insertDH5(struct hashTable *table, int *key, void *value);

/* Insert the given key into the given hash table comparing the
    hash of the given key to the keys in the table already,
    trying to place it at the next interval hash2key distance away 
    from where it would otherwise have been placed,
    continuing this process until a free spot is found and then
    the value is placed in this location. If used >= size, 
    the function returns doing nothing. */
void insertDH(struct hashTable *table, int *key, void *value, int hash2key);

/* Allocates space for a hash table and assigns its hash, insert
    and print (for a single data item) functions. */
struct hashTable *create(int tableSize, int *(*hash)(void *), 
    void (*insert)(struct hashTable *, int *, void *), 
    void (*print)(void *));

/* 
    Insert the item in the hash table.
*/
void insert(struct hashTable *table, void *value);

/* Prints the given hash table. */
void printTable(struct hashTable *table);

/* Free all data allocated by the hash table. */
void freeTable(struct hashTable *table);
