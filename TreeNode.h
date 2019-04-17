#ifndef TREENODE_H
#define TREENODE_H
#include <stdbool.h>

typedef struct TreeNode *TreeNodePointer;

typedef struct TreeNode_Struct{
  char value;
  TreeNodePointer children[100];
  int totalChildren;
}TreeNode;

bool hasChildren(TreeNode n);
void addChildNode(TreeNode root, TreeNode child);
void addChildChar(TreeNode root, char charValue);

#endif
