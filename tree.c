#include <assert.h>

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <limits.h>
#include <time.h>
#include <string.h>

#include "tree.h"
#include "linkedlist.h"




treeptr	new_treenode(void * data){
	extern struct list *	list_new(void);
	treeptr rv = malloc(sizeof(struct treenode));
	
	if (data == NULL)
		fprintf(stderr, "file %s line %i: Warning: Added a treenode with NULL data. Is this intentional?\n", __FILE__, __LINE__);
	
	rv->data = data;
	rv->children = list_new();
	rv->expanded = rv->red = rv->crossed_out = 0;
	
	return rv;	
}

void	attach(treeptr child, treeptr parent){
	extern void list_push(struct list *, void *);
	
	assert(parent != NULL);
	assert(child != NULL);
	assert(parent -> children != NULL);

	list_push(parent->children, child);
}


void expand(treeptr node, struct list (*children_of)(void *)){
	/*Generates all children of a node and expands it.
	Gives a warning if node is expanded.
	Consults a function to find out how many and which data (such as chess boards) are the "children" of this node's datum (eg chess board)*/
	struct list 	child_data;
	void *		datum;
	
	assert(children_of != NULL);
	
	if (node == NULL){
		fprintf(stderr, "file %s line %i: Warning: Attempted to expand NULL node. Did nothing.\n", __FILE__, __LINE__);
		return;
	}
	
	if (node->expanded){
		fprintf(stderr, "file %s line %i: Warning: Attempted to expand node %p which is already expanded. Did nothing.\n", __FILE__, __LINE__, node);
		return;
	}
	
	if(node->data != NULL)
		fprintf(stderr, "file %s line %i: Warning: Node %p to be expanded has NULL as data. Defective?\n", __FILE__, __LINE__, node);
	/*done with assertions*/
	
	child_data = children_of(node->data);
	
	foreach(datum, child_data)		
		attach(new_treenode(datum), node);
	
	node->expanded = 1;
}

void free_tree(treeptr node, void (*data_destroyer)(void *)){
/* (recursive) frees a treenode after freeing all its children. Before doing so, passes data to function data_destroyer, which can be "free" or something more complex. Warning: Does not remove this node from its parent's child list!*/
	int ___curr_index;
	treeptr child;
	
	if (node == NULL){
		fprintf(stderr, "file %s line %i: Warning: Attempted to free NULL node.\n", __FILE__, __LINE__);
		return;
		}
	
	foreach(child, node->children)
		free_tree(child);
	
	if (data_destroyer != NULL)
		(*data_destroyer)(node->data);
	
	list_destroy(&node->children, NULL);
	free(node);
}