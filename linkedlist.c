#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <string.h>

struct listnode{
	void *value;
	struct listnode *next;
};

struct listnode *list_find(struct listnode *entry, void *x){
/*returns element containing x*/

	if (entry == NULL || entry->value == x)
		return entry;
	else
		return list_find(entry->next, x);
}

struct listnode * list_add(struct listnode *entry, void *x){
/*adds x after specified entry. If given NULL as arument, creates a new list.
	Returns pointer to entry, or to first list element if NULL was the list added to.*/

	struct listnode *newentry;
	newentry = malloc(sizeof(struct listnode));
	newentry->value = x;

	if (entry != NULL){
		newentry->next = entry->next;
		entry->next = newentry;
		return entry;
	}
	else {
		newentry->next = NULL;
		return newentry;
	}
}

void list_remove(struct listnode **pentry, void *x){
/*deletes first entry with x, that occurs after (or at) entry *entry*/
	struct listnode * b;
	struct listnode * a;
	struct listnode * entry;

	if (pentry == NULL)
		return;

	entry = *pentry;

	b = entry;
	while (b != NULL && b->next != NULL && b->next->value != x)
		b = b->next;
	/*at end of this b is the last element before the one with x.*/

	a = list_find(entry, x)->next;
	free(b->next);
	b->next = a;
}

void list_end(struct listnode *lastentry){
/*makes the specified entry the last entry, and deletes all behind that*/
/*gives error on empty list*/
	struct listnode *curr_entry;
	if (lastentry == NULL) fprintf(stderr, "line %i: function list_end was passed NULL as argument\n", __LINE__);

	curr_entry = lastentry->next;
	lastentry->next = NULL;

	while(curr_entry != NULL){
		struct listnode *next;
		next = curr_entry->next;
		free(curr_entry);
		curr_entry = next;
		}
}

void list_destroy(struct listnode **np_ptr){
	extern void list_end(struct listnode *);
	#define np *np_ptr
	
	if (np_ptr == NULL || np == NULL)
		return;

	list_end(np);
	free(np);
	np = NULL;
	#undef np
}

struct listnode * list_push(struct listnode *np, void *x){
/*adds x before specified entry, which must be a first list element or NULL. Returns pointer to entry added*/
	struct listnode *newentry;

	newentry = malloc(sizeof(struct listnode));
	newentry->value = x;
	newentry->next = np;

	return newentry;
}

void * list_pop(struct listnode **np_ptr){
/*Given a pointer to listnode pointer, returns the first value on the list ((*np_ptr)->value), deletes the node pointed at by *np_ptr, sets *np_ptr to point to the next node, if any, or to NULL otherwise.*/
	struct listnode *	oldhead;
	void *			oldheadval;

	if (np_ptr == NULL || *np_ptr == NULL)
		return NULL;

	else {
		oldhead = *np_ptr;
		oldheadval = oldhead->value;
		*np_ptr = oldhead->next;
		free(oldhead);

		return oldheadval;
	}
}
