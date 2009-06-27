/*library to provide a generic tree (not binary or search or anything) of void pointers, and some tree functions*/

/*struct tree {
	struct node *	root;	
}		I don't need this. If I just consider any node to be a tree, then all subtrees are already created by creating the tree, and I can run tree algos on nodes instead of trees*/

/* #include "linkedlist.h"*/

struct treenode {
	void *		data;
	struct list 	children;	/*linked list of this node's children, not nessecarily in any particular order*/
	
	int expanded;			/*Often a tree, such as the tree of all possible chess boards where black is next that can follow from a given board (by legal moves of black and white), already exists, and one is searching for a particular node; such as a  */

	int red;				/*a means to color this node. Use optional.*/
	int crossed_out;		/*a second means to mark this node. Use optional.*/
};

typedef struct treenode *	treeptr;


treeptr	new_treenode(void * data);
/*creates a new treenode with the given data, no children (empty list), which is not expanded (or red or crossed out). Returns a pointer. Does not insert it anywhere.*/

void 	free_tree(treeptr, void (*data_destroyer)(void *));
/* (recursive) frees memory taken up by a treenode after freeing all its children. Before doing so, passes data address to function data_destroyer, which can be "free" or something more complex. Warning: Does not remove this node from its parent's child list!*/

void		attach(treeptr child, treeptr parent);
/*adds the treenode, 'child', as a child to the treenode, 'parent'. Warning: This does not remove the child from any other parent it may have. Child will usually be new_treenode(data) Same as list_push(parent->children, child).*/

void		expand(treeptr node, struct list (*children_of)(void *data));
/*Not sure if this is a good idea, but:
	Generates all children of a node and expands it. Gives a warning if node is expanded. Consults a function to find out how many and which data (such as chess boards) are the "children" of this node's datum (eg chess board)*/





















//treeptr	new_treenode2(void * data, int is_expanded, int is_red, int is_crossed, /*variable length list of pointers to children*/);
/*creates a new treenode to specification. Returns a pointer. Does not insert it anywhere.*/
