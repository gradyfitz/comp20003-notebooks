#ifndef __UTILS__
#define __UTILS__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>
#include <signal.h>


#define SIZE 9
#define _XOPEN_SOURCE 500

/**
 * Data structure containing the information about the game state
 */

typedef struct {
	int8_t x,y;
} position_s;

typedef struct {
	int8_t field[SIZE][SIZE];
	position_s cursor;
	bool selected;
} state_t;


/**
* Move type
*/
typedef enum moves_e{
	left=0,
	right=1,
	up=2,
	down=3
} move_t;


/**
 * Search Node information
 */
struct node_s{
    int depth;
    move_t move;
    state_t state;
    struct node_s* parent;
};

typedef struct node_s node_t;

/**
 * GLOBAL VARIABLES
*/

state_t solution[SIZE*SIZE];
move_t  solution_moves[SIZE*SIZE];
int solution_size;

int generated_nodes;
int expanded_nodes;

bool ai_run; //Run AI
bool show_solution; //Play solution found by AI algorithm
int budget; // budget for expanded nodes



/**
 *  Useful functions for AI algorithm
 */

// Updates the field and cursor given the selected peg and the jump action chosen
void execute_move_t(state_t* state, position_s* selected_peg, move_t jump);

// returns true if move is legal
bool can_apply(state_t *board, position_s* selected_peg, move_t jump);

// Check if game is over
bool won(state_t *board);

// returns number of pegs in board
int num_pegs( state_t *board );

/**
 * Used for human games
*/
void rotateBoard(state_t *board);
bool select_peg(state_t *board);
bool moveUp(state_t *board);
bool moveLeft(state_t *board); 
bool moveDown(state_t *board); 
bool moveRight(state_t *board);
int8_t validMovesUp(state_t *board);
bool gameEndedForHuman(state_t *board);

void initialize(state_t *board, int8_t layout);

/**
 * Output functions
*/
void drawBoard(state_t *board);
char* action_cstr(move_t move);
void print_solution();
void play_solution();


#endif
