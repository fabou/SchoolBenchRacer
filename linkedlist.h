struct listnode{
	void *value;
	struct listnode *next;
};

struct listnode *list_find(struct listnode *entry, void *x);
	/*returns element containing x*/

struct listnode * list_add(struct listnode *entry, void *x);
	/*adds x after specified entry. If given NULL as arument, creates a new list.
	Returns pointer to entry, or to first list element if NULL was the list added to.*/

void list_remove(struct listnode *entry, void *x);
	/*deletes first entry with x, that occurs after (not at) entry entry*/

void list_end(struct listnode *lastentry);
	/*makes the specified entry the last entry, and deletes all behind that*/
	/*gives error on empty list*/

void list_destroy(struct listnode **firstentry);
	/*Frees all memory associated with list entries. Must use with first entry of a list, else: memory leak occurs.*/
	/*Remember to set any list pointer to NULL after destroying it...*/

void * list_pop(struct listnode **firstentry);
/*Returns the value of the first entry and removes it from the list*/

struct listnode * list_push(struct listnode *entry, void *x);
/*adds x before specified entry, which must be a first list element or NULL. Returns pointer to entry added*/


#define foreach(laufvariable, linked_list) for (___curr_lnode=linked_list, laufvariable = (___curr_lnode) ? ___curr_lnode->value : laufvariable;	___curr_lnode != NULL;	___curr_lnode = ___curr_lnode->next, laufvariable = (___curr_lnode) ? ___curr_lnode->value : laufvariable)
	struct listnode * ___curr_lnode;
	/*foreach(laufvariable, linked_list) iterates over all *values* in a linked list*/
	/*warning: nested foreach will only work if the inner foreach has its own, independent, struct listnode * ___curr_lnode; -- ugly!*/


