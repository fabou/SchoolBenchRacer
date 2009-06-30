#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <string.h>

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
void * list_value(struct list *, int index);
int list_find(struct list *, void *value);
void list_push(struct list *, void *value);
void * list_pop(struct list *);
void list_unshift(struct list *, void *value);
void * list_shift(struct list *);
void list_rotate(int by);
void * list_rshift(struct list *);
void list_add_after(struct list *list, void *data, int index);
void list_add_before(struct list *list, void *data, int index);

/*helper functions, not to be accessed from outside the library*/

struct listnode *	new_listnode(void * value, struct listnode *prev, struct listnode *next){
	/*this is a helper function for the others, and only used in this file*/
	/*creates a new node with the specified links and returns a pointer*/
	struct listnode *rv = malloc(sizeof(struct listnode));	/*rv : returnvalue*/
	
	rv->value = value;
	rv->prev = prev;
	rv->next = next;
	
	return rv;		
}

void free_node(struct listnode *node, void (*value_destroyer)(void *)){
	/*frees the memory taken by  a listnode, but calls value_destroyer on its value pointer first.*/
	/*value_destroyer will usually be 'free' or NULL.*/
		
	if (node != NULL){
		if (value_destroyer != NULL)
			(*value_destroyer)(node->value);
		free(node);
	}
}

struct listnode *	list_node(struct list *list, int index){
	/*returns a pointer to list's node with index 'index'. O(list->size)*/
	/*return NULL if such a node, or the list, does not exist. Also return NULL if a negative index is given*/
	struct listnode *rv;
	#define highest_index list->size - 1
		
	if (list != NULL && list->size > 0 && index >= 0 && index <= highest_index /*that is, if the specified node exists*/) {
		int i;
		for (i=0, rv = list->head; i < index; i++)
			rv = rv->next;
		return rv;
	}
	else
		return NULL;
#undef highest_index
}


/*functions to be accessed from outside*/

struct list * 	list_new(void){
	/*creates a new, emtpy list and returns a pointer.*/
	struct list * rv = malloc(sizeof(struct list));
	
	rv->size = 0;
	rv->head = NULL;
		
	return rv;	
}

void list_add_before(struct list *list, void *data, int index){
/*adds x before the node with the specified index. Will not work on empty lists. Will do nothing if the index does not exist.*/
	#define highest_index list->size - 1
	
	if (list != NULL && list->size > 0 && index >= 0 && index <= highest_index /*that is, the node before which the new node is to be added, exists*/){
		struct listnode * successor = list_node(list, index);
		struct listnode * predecessor = successor->prev;
		
		struct listnode * newnode = new_listnode(data, predecessor, successor);
		predecessor		->next = newnode;
		successor		->prev = newnode;
		
		if (index == 0)
			list->head = newnode;
		
		list->size++;
	}
	
	else
		fprintf(stderr, "file %s line %i: attempted to add something before index %i of list %p, whose highest index is %i. Doing nothing.\n" __FILE__, __LINE__, index, list, (list != NULL) ? highest_index : -1);

#undef highest_index list->size - 1
}

void list_add_after(struct list *list, void *data, int index){
/*adds x after the node with the specified index. Will not work on empty lists. Will do nothing if the index does not exist.*/
	#define highest_index list->size - 1
	
	if (list != NULL && list->size > 0 && index >= 0 && index <= highest_index /*that is, the node after which the new node is to be added, exists*/){
		struct listnode * predecessor = list_node(list, index);
		struct listnode * successor = predecessor->next;
		
		struct listnode * newnode = new_listnode(data, predecessor, successor);
		predecessor		->next = newnode;
		successor		->prev = newnode;
		
		list->size++;
	}
	
	else
		fprintf(stderr, "file %s line %i: attempted to add something before index %i of list %p, whose highest index is %i. Doing nothing.\n" __FILE__, __LINE__, index, list, (list != NULL) ? highest_index : -1);

#undef highest_index list->size - 1
}

void list_remove(struct list * list, int index, void (*value_destroyer)(void *)){
/*deletes the list node in the specified position from the list. Third argument gives a function that will be applied to the value pointer. Specify free to free the memory at that address, NULL to leave it be, or another function.*/
	#define highest_index list->size - 1
	
	if (list != NULL && list->size > 0 && index >= 0 && index <= highest_index /*the node exists*/){
		struct listnode *moribund = list_node(list, index);
		
		moribund->prev	->next = moribund->next;
		moribund->next	->prev = moribund->prev;
		
		if (index == 0)
			list->head = (list->size > 1) ? moribund->next : NULL;
		
		free_node(moribund);
		
		list->size--;
	}
	
	else
		fprintf(stderr, "file %s line %i: attempted to remove nonexistent element with index %i from list %p, whose highest index is %i. Doing nothing.\n" __FILE__, __LINE__, index, list, (list != NULL) ? highest_index : -1);	
#undef highest_index list->size - 1
}

void *list_value(struct list *list, int index){
	/*returns the value at the specified position. O(list->size). Returns NULL if no value. This is indistinguishable from the node existing and actually storing NULL.*/
	if (list != NULL && list->size > 0 && index >= 0 && index <= list->size - 1 /*the node exists*/)
		return list_node(list, index)->value;
	
	else {
		fprintf(stderr, "file %s line %i: Warning: Attempted to return value of nonexistent list element with index %i from list %p, whose highest index is %i. Returned NULL.\n" __FILE__, __LINE__, index, list, (list != NULL) ? highest_index : -1);
		return NULL;
	}
}

int 	list_find(struct list *list, void *value){
/*returns the first index that has the given value. O(list->size). Returns -1 if the specified pointer is not in the list, or, if the list does not exist.*/
	struct listnode * current_listnode;
	
	if (list == NULL)
		fprintf(stderr, "file %s line %i: Warning: attempted to search for the pointer %p in a NULL list. Returning 'not in list' (-1)\n" __FILE__, __LINE__, value);
	
	if (list != NULL && list->size > 0)
		for (rv = 0, current_listnode = list->head; rv < list->size; rv++, current_listnode = current_listnode->next)
			if (current_listnode->value == value)
				return rv;

	return -1;
}

void list_push(struct list *, void *value){
/*adds value to the end of specified list.*/
/*if the list is empty, a first value is created*/
	if (list->size == 0){
		list->head = new_listnode(value, NULL, NULL);
		list->head->next = list->head->prev = list->head;
	}
	else 
		list_add_after(list, value, list->size - 1);
}

void * list_pop(struct list *){
/*Returns last entry of specified list and then removes it. Returns NULL when applied to an empty list or when there is no list.*/
	void * rv;
	
	if (list != NULL && list->size > 0){
		rv = list->head->prev->value;
		list_remove(list, list->size - 1, NULL);
		return rv;
	}
	else
		return NULL;
}

void list_unshift(struct list *, void *value){
/*adds value before first entry of specified list.*/
/*if the list is empty, a first value is created*/
	if (list->size == 0){
		list->head = new_listnode(value, NULL, NULL);
		list->head->next = list->head->prev = list->head;
	}
	else 
		list_add_before(list, value, 0);
}

void * list_shift(struct list *){
/*Returns first entry of specified list and then removes it. Returns NULL when applied to an empty list, or when there is no list.*/
	void * rv;
	
	if (list != NULL && list->size > 0){
		rv = list->head->value;
		list_remove(list, 0, NULL);
		return rv;
	}
	else
		return NULL;
}

void list_rotate(struct list *list, int by){
/*rotates the list by 'by', clockwise, i.e. rotates what was at 0 into the 1 position, etc.*/
	
	if (list == NULL){
		fprintf(stderr, "file %s, line %i: Warning: attempt made to rotate nonexistent (NULL) list.\n", __FILE__, __LINE__);
		return;
	}
	
	if (list->size == 0)
		return;
	
	if (by > 0)
		while (by != 0){
			list->head = list->head->prev;
			by--;
		}
		
	else /*if by [was] < 0 [when the above if-condition was evaluated]*/
		while (by != 0){
			list->head = list->head->next;
			by++;
		}
}

void * list_rshift(struct list *list){
	void * rv = NULL;
	
	if (list == NULL)
		fprintf(stderr, "file %s, line %i: Warning: attempt made to shift a value off nonexistent (NULL) list. Returning NULL.\n", __FILE__, __LINE__);
	else if (list->size == 0)
		fprintf(stderr, "file %s, line %i: Warning: attempt made to shift a value off empty list %p. Returning NULL.\n", __FILE__, __LINE__, list);
	else {
		rv = list->head->value;
		list->head = list->head->next;
	}
	
	return rv;
}


void list_destroy (struct list *list, void(*value_destroyer)(void*)){
	/*Destroys all nodes in a given list, making it blank. Applies value_destroyer to each value before destroying its node.*/
	
	if (list == NULL){
		fprintf(stderr, "file %s, line %i: Warning: attempt made to destroy NULL list. Doing nothing.\n", __FILE__, __LINE__);
		return;
	}
	
	if (list->head == NULL){
		assert(list->size == 0)
		return;	/*list already blank*/
	}
	
	/*linearize list*/
	list->head->prev	->next = NULL;
	list->head		->prev = NULL;
		
	while (list->head != NULL){
		struct listnode * moribund = list->head;
		list->head = list->head->next;
		free_node(moribund, value_destroyer);
		list->size--;
	}
	assert(list_size == 0);
}
