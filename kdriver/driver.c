/*driver: plays the car racing game against a human or by itself*/

#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <string.h>

#define ifdebug 			if (cmdline.verbose_flag)
#define rep 			ifdebug fprintf(stderr, "alive, line: %i\n", __LINE__)
#include "matrixmacros.h"

struct s_map {
		int Xsize;
		int Ysize;
		int ** map;
	};

struct s_car_state{
	int x;
	int y;
	int vx;
	int vy;
	int has_to_skip_next_turn;
};

int MyMove(state_before_move){	/*returns a number between 0 and 9 representing acceleration*/

	/*Here's a bunch of static variables*/


	/*How does it decide how to move? One way would be to search a tree for the most favorable state - but how to evaluate favorableness?*/

	/*A brute force thing would be to calculate, assuming one is alone on the track, the shortest sequence of moves that gets one thru a finish square*/
	/*this would then just be executed without regard for collisions*/
	/*if one is sufficiently far in the lead, this is the ideal strategy, so I'll be able to use this in a better version*/							/*(actually its not nessecarily ideal, as a collision with another car can be a good thing - i decelerates you.)*/

	/*So I'll just do that*/






}

int *	Strategy_of_one_who_is_unaware_of_the_existence_of_others(const struct s_map map, const int my_x0, const int my_y0, const int my_vx0, const int my_vy0, const int i_skip_initial_turn)  /*=my_initial_position, my_initial_velocity, do I skip next turn*/){	/*ToDo: shorter name.*/
	/*returns a sequence of moves that is perfect, assuming no collisions with other cars occur along the way*/

	/*So how does this now proceed? It builds a tree of single player game states*/
	/*A state is like [a scenery with:] a map with the car and velocity vector drawn into it, and a turn counter standing next to this... and: a red lamp on the wall on the left of the turn map, labeled "Skip Next Turn"; a banner above the map saying "YOU HAVE WON" (or nothing)*/ /*And a
	/*Should the program build a tree of these states?*/

	/*At the top the current state, below each state, states reachable from there.*/	/*note that the turn counter will be equal to the depth in the tree that a state is on (turn 1: top level, "level 1", turn 2, level 2, ...)*/
	/*there's an infinite number of states as you can always go in circles, but a finite number of states with less than 1, 2, 3, 4, 5, ... on the turn counter*/
	/*and as soon as we find a state where we've won - we need no longer explore states that have higher values on the turn counter, and where we've not yet won.*/

	/*So, we'll begin at the initial state, and move to one of the states below that, and from there... */

	/* I may want to use one of these
		a.) A function to determine reliably, for a given state, a minimum (Lbound) for how many turns it will take to go from here to a victory*/

	/*A better way might be to use some sort of dynamic programming to calculate the shortest path from the current square, (with the current velocity vector) to the all other squares...*/

}



















}
