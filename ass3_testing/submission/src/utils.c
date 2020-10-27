#include "utils.h"
#include "layouts.h"

void execute_move_t(state_t* state, position_s* selected_peg, move_t jump) {
    int8_t x = selected_peg->x;
    int8_t y = selected_peg->y;

    
    switch (jump) {
    case up:          //Jump up
        state->field[x][y-2] = 'o';
        state->field[x][y-1] = '.';
        state->field[x][y-0] = '.';
        state->cursor.y = y-2;
        break;

    case down:         //Jump down
        state->field[x][y+0] = '.';
        state->field[x][y+1] = '.';
        state->field[x][y+2] = 'o';
        state->cursor.y = y+2;
        break;

    case left:         //Jump left
        state->field[x-2][y] = 'o';
        state->field[x-1][y] = '.';
        state->field[x-0][y] = '.';
		state->cursor.x = x-2;
        break;

    case right:          //Jump right
        state->field[x+0][y] = '.';
        state->field[x+1][y] = '.';
        state->field[x+2][y] = 'o';
		state->cursor.x = x+2;
        break;

    }
	
}

bool can_apply(state_t *board, position_s* selected_peg, move_t jump){
    
    // Can select a Peg
    if ( board->field[ selected_peg->x ][ selected_peg->y ] !='o')  return false;
    
    //Determine if move is legal
    switch (jump) {
        case up:          
            if(  selected_peg->y < 2) return false;
            if( board->field[ selected_peg->x ][ selected_peg->y - 1 ] !='o')  return false;
            if( board->field[ selected_peg->x ][ selected_peg->y - 2 ] !='.')  return false;
            break;
            
        case down:         
            if( selected_peg->y > SIZE - 3 ) return false;
            if( board->field[ selected_peg->x ][ selected_peg->y + 1 ] !='o')  return false;
            if( board->field[ selected_peg->x ][ selected_peg->y + 2 ] !='.')  return false;
            break;

        case left:         
            if( selected_peg->x < 2) return false;
            if( board->field[ selected_peg->x - 1 ][ selected_peg->y ] !='o')  return false;
            if( board->field[ selected_peg->x - 2 ][ selected_peg->y ] !='.')  return false;
            break;

        case right:          
            if( selected_peg->x > SIZE - 3) return false;
            if( board->field[ selected_peg->x + 1 ][ selected_peg->y ] !='o')  return false;
            if( board->field[ selected_peg->x + 2 ][ selected_peg->y ] !='.')  return false;
            break;
    }
    // Can Jump

    
    return true;

}


bool won(state_t *board) {
	int8_t x,y;
	int8_t count=0;

	for (x=0;x<SIZE;x++) {
		for (y=0;y<SIZE;y++) {
			if (board->field[x][y]=='o') {
				count++;
             
			}
            // If more than one peg is left, you haven't won yet
            if( count > 1) return false;
		}
	}
	//If only one is left
	return count == 1;

}

int num_pegs( state_t *board ){
	int count = 0;
	for (int y=0;y<SIZE;y++) {
		for (int x=0;x<SIZE;x++) {
			count+=board->field[x][y]=='o';
		}
	}
	return count;
}


void rotateBoard(state_t *board) {
	int8_t i,j,n=SIZE;
	int8_t tmp;
	for (i=0; i<n/2; i++){
		for (j=i; j<n-i-1; j++){
			tmp = board->field[i][j];
			board->field[i][j] = board->field[j][n-i-1];
			board->field[j][n-i-1] = board->field[n-i-1][n-j-1];
			board->field[n-i-1][n-j-1] = board->field[n-j-1][i];
			board->field[n-j-1][i] = tmp;
		}
	}
	i = board->cursor.x;
	j = board->cursor.y;

	board->cursor.x = -(j-n/2)+n/2;
	board->cursor.y = (i-n/2)+n/2;
}

bool select_peg(state_t *board) {
	int8_t x,y,(*field)[SIZE];
	bool selected;

	x = board->cursor.x;
	y = board->cursor.y;
	field = board->field;
	selected = board->selected;

	if (field[x][y]!='o') return false;
	board->selected = !selected;
	return true;
}

bool moveUp(state_t *board) {
	int8_t x,y,(*field)[SIZE];
	bool selected;

	x = board->cursor.x;
	y = board->cursor.y;
	field = board->field;
	selected = board->selected;

	if (selected) {
		if (y<2) return false;
		if (field[x][y-2]!='.') return false;
		if (field[x][y-1]!='o') return false;
		if (field[x][y-0]!='o') return false;
		field[x][y-2] = 'o';
		field[x][y-1] = '.';
		field[x][y-0] = '.';
		board->cursor.y = y-2;
		board->selected = false;
	} else {
		if (y<1) return false;
		if (field[x][y-1]==' ') return false;
		board->cursor.y = y-1;
	}
	return true;
}

bool moveLeft(state_t *board) {
	bool success;
	rotateBoard(board);
	success = moveUp(board);
	rotateBoard(board);
	rotateBoard(board);
	rotateBoard(board);
	return success;
}

bool moveDown(state_t *board) {
	bool success;
	rotateBoard(board);
	rotateBoard(board);
	success = moveUp(board);
	rotateBoard(board);
	rotateBoard(board);
	return success;
}

bool moveRight(state_t *board) {
	bool success;
	rotateBoard(board);
	rotateBoard(board);
	rotateBoard(board);
	success = moveUp(board);
	rotateBoard(board);
	return success;
}


int8_t validMovesUp(state_t *board) {
	int8_t x,y;
	int8_t count=0;
	for (x=0;x<SIZE;x++) {
		for (y=SIZE-1;y>1;y--) {
			if (board->field[x][y]=='o') {
				if (board->field[x][y-1]=='o') {
					if (board->field[x][y-2]=='.') {
						count++;
					}
				}
			}
		}
	}
	return count;
}

bool gameEndedForHuman(state_t *board) {
	int8_t i,count=0;
	for (i=0;i<4;i++) {
		count+=validMovesUp(board);
		rotateBoard(board);
	}
	return count==0;
}

void initialize(state_t *board, int8_t layout) {
	int8_t x,y;

	if( layout > NUM_LAYOUTS - 1) layout = 0;
	
	board->cursor.x = 4;
	board->cursor.y = 4;
	board->selected = false;

	memset(board->field,0,sizeof(board->field));
	for (y=0;y<SIZE;y++) {
		for (x=0;x<SIZE;x++) {
			board->field[x][y]=configuration[layout][y][x*2];
		}
	}
}


void drawBoard(state_t *board) {
	int8_t x,y,count=0;

	// move cursor to home position
	printf("\033[H");

	for (y=0;y<SIZE;y++) {
		for (x=0;x<SIZE;x++) {
			count+=board->field[x][y]=='o';
		}
	}
	printf("peg-solitaire.c %7d pegs\n",count);
	printf("                             \n");

	for (y=0;y<SIZE;y++) {
		for (x=0;x<14-SIZE;x++) {
			printf(" ");
		}
		for (x=0;x<SIZE;x++) {
			if (board->cursor.x == x && board->cursor.y == y) {
				if (board->selected) {
					printf("\b|\033[7m%c\033[27m|",board->field[x][y]);
				} else {
					printf("\033[7m%c\033[27m ",board->field[x][y]);
				}
			} else {
				printf("%c ",board->field[x][y]);
			}
		}
		for (x=0;x<14-SIZE;x++) {
			printf(" ");
		}
		printf("\n");
	}
	printf("                            \n");
	printf("   arrow keys, q or enter   \n");
	printf("\033[A"); // one line up
}

char* action_cstr(move_t move){

	switch (move) {
		case up:  
			return "Up";
		break;

		case down: 
			return "Down";
		break;

		case left:    
			return "Left";
		break;

		case right:  
			return "Right";
		break;

	}
	return " ";
}

void print_solution(){

	for(int i=0; i< solution_size; i++)
		printf("    %d - %s                              \n", i+1, action_cstr(solution_moves[i]));
		
}

void play_solution(){
	for(int i=0; i <= solution_size; i++){
		drawBoard(&(solution[i]));
		usleep(500000);
		
		if( i < solution_size){
			//Reverse action
			switch ( solution_moves[i] ) {
				case up:          
					solution[i].cursor.y = solution[i+1].cursor.y+2;
					solution[i].cursor.x = solution[i+1].cursor.x;
					break;
				case down:         	
					solution[i].cursor.y = solution[i+1].cursor.y-2;
					solution[i].cursor.x = solution[i+1].cursor.x;
					break;
				case left:         
					solution[i].cursor.x = solution[i+1].cursor.x+2;
					solution[i].cursor.y = solution[i+1].cursor.y;
					break;
				case right:          
					solution[i].cursor.x = solution[i+1].cursor.x-2;
					solution[i].cursor.y = solution[i+1].cursor.y;
					break;
				}
			solution[i].selected = true;
			drawBoard(&(solution[i]));
			usleep(500000);
		}
	}
}
