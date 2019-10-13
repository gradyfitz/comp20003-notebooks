CC=gcc
#CPPFLAGS=-Wall   -O3 -std=gnu99
CPPFLAGS=   -g  -std=gnu99

SRC=utils.o priority_queue.o ai.o pacman.o 
TARGET=pacman

all: $(SRC)
	$(CC) -o $(TARGET) $(SRC) $(CPPFLAGS) -lncurses -lm

clean:
	rm -f $(TARGET) *.o

