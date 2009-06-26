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

struct listnode *	list_node_nr(struct list *list, int index){
	/*returns a pointer to the node with the specified index. O(list->size)*/
	
	
	
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
/*adds x before the node with the specified index. The index of whatever is there, and whatever is after there, will increase by 1.*/
/*list_add_before(..., ..., P) with P >= list->size will give an error. list_add_after(..., ..., 0) will give an error if the list is empty!*/
	
}

void list_add_after(struct list *list, void *data, int index){
/*adds x after specified entry*/
/*gives an error if list is empty*/
	
	
}

void list_remove(struct list * list, int index, void (*value_destroyer)(void *)){
/*deletes the list node in the specified position from the list. Third argument gives a function that will be applied to the value pointer. Specify free to free the memory at that address, NULL to leave it be, or another function.*/

	
	
}

void *		list_value(struct list *list, int index){
	/*returns the value at the specified position. O(list->size)*/
	
	
}

int 			list_find(struct list *list, void *value){
/*returns the first index that has the given value. O(list->size)*/

	

}

void list_push(struct list *, void *value){
/*adds value before first entry of specified list.*/
	
}

void * list_pop(struct list *){
/*Returns first entry of specified list and then removes it. Returns NULL when applied to an empty list, or when the list pointer given is itself NULL.*/
	
	
}

void 		list_destroy (struct list *list, void(*value_destroyer)(void*)){
	/*Destroys all nodes in a given list, making it blank. Applies value_destroyer to each value before destroying its node.*/
	while (list->head != NULL){
		struct listnode *	new_head;
		new_head = (list->head->next == list->head) ? NULL : list->head->next;
		node_free(list->head, value_destroyer);
		list->head = new_head;
	}
	list->size = 0;
}
