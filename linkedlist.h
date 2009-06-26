/*this provides lists of void pointers*/
/*the lists are implemented as circular doubly linked lists*/

struct list{
	struct listnode *	head;	/*0th node*/
	int				size;		/*number of elements in the list*/
};

struct listnode{
	void *			value;	/*the actual thing stored in the list*/
	struct listnode *	next;	/*node's successor. may be either the one with the next higher index, or the 0th node*/
	struct listnode *	prev;	/*node's predecessor. may be either the one with the next lower index, or the last node*/
};


/*header needs to be rewritten using comments and definitions of public functions in linkedlist.c*/






















/*the below needs adaptation*/
#define foreach(laufvariable, linked_list) for (___curr_lnode=linked_list, laufvariable = (___curr_lnode) ? ___curr_lnode->value : laufvariable;	___curr_lnode != NULL;	___curr_lnode = ___curr_lnode->next, laufvariable = (___curr_lnode) ? ___curr_lnode->value : laufvariable)
	struct listnode * ___curr_lnode;
	/*foreach(laufvariable, linked_list) iterates over all *values* in a linked list*/
	/*warning: nested foreach will only work if the inner foreach has its own, independent, struct listnode * ___curr_lnode; -- ugly!*/


