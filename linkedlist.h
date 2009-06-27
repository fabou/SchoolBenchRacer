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

void list_remove(struct list *, int index, void (*value_destroyer)(void *));
/*deletes the list node in the specified position from the list. Third argument gives a function that will be applied to the value pointer. Specify free to free the memory at that address, NULL to leave it be, or another function. O(index)*/

void * list_value(struct list *, int index);
/*returns the value at the specified position. Returns NULL, and prints a warning to stderr, if the index is too large (there's no such value). O(index)*/

int list_find(struct list *, void *value);
/*returns the lowest index in the list that has the given value. Returns -1 if the specified pointer is not in the list, or, if the list does not exist. O(list->size)*/

void list_push(struct list *, void *value);
/*adds value as last entry of specified list, which may be empty (but not NULL) O(1)*/

void * list_pop(struct list *);
/*Returns last entry of specified list and then removes it. Returns NULL when applied to an empty list or when there is no list. O(1)*/

void list_unshift(struct list *, void *value);
/*adds value as first entry of specified list, which may be empty (but not NULL) O(1)*/

void * list_shift(struct list *);
/*Returns first entry of specified list and then removes it. Returns NULL when applied to an empty list, or when there is no list. O(1)*/

void list_rotate(int by);
/*Rotates the 'list' 
	(which is actually a ring, where position 0 is simply the one marked as 'zero', 1 the one clockwise from there, list->size-1 the one counterclockwise from there, etc...)
clockwise the specified number of times. (Imagine the list as sitting on a dial where the positions are numbered.)

Example rotation of a 101 member list by +1:

what was at index:		is now at index:
100					0
0					1
1					2

of a 12 member list by +3:

what was at index:		is now at index:
10					1
11					2
0					3
1					4

i					i+3 mod 12
*/




void * list_rshift(struct list *);
/*Returns first entry of specified list. The first entry is then removed, and added back onthe end. This is akin to rotating all elements through position 0. O(1)*/

void list_add_after(struct list *list, void *data, int index);
/*adds x after the node with the specified index. Will not work on empty lists. Will do nothing if the index does not exist. O(index)*/

void list_add_before(struct list *list, void *data, int index);
/*adds x before the node with the specified index. Will not work on empty lists. Will do nothing if the index does not exist. O(index)*/




#define foreach(laufvariable, list) if (list != NULL && list->size > 0) for (___curr_index = 0, laufvariable = list->head->value;  ___curr_index < list->size; list_rotate(list, -1), ___curr_index++)

int ___curr_index;
/*foreach(laufvariable, linked_list) iterates over all *values* in a linked list*/
/*warning: at the moment nested foreach will only work if the inner foreach has its own, independent local variable int ___curr_index;


