#include <stdio.h>
#include "TreeNode.h"
#include <stdbool.h>

bool hasChildren(TreeNode n)
{
  return (n.totalChildren > 0);
}

//assumes that totalChildren will always be capped at 100
TreeNode addChildNode(TreeNode root, TreeNode child)
{
  if (root.totalChildren < 100)
  {
    root.children[root.totalChildren] = *((TreeNodePointer *) &child);
    root.totalChildren += 1;
  }

  return root;
}

TreeNode addChildChar(TreeNode root, char charValue)
{
  TreeNode temp;
  temp.value = charValue;

  if (root.totalChildren < 100)
  {
    root.children[root.totalChildren] = *((TreeNodePointer *) &temp);
    root.totalChildren = root.totalChildren + 1;
  }

  return root;
}


void printTreeStacked(TreeNode root)
{
  printf("%c : [", root.value);
  TreeNode temp;
  for(int i = 0; i < root.totalChildren; i++)
  {
    temp = *((TreeNode *) &root.children[i]);
    if (i != root.totalChildren - 1)
      printf("%c, ", temp.value);
    else
      printf("%c", temp.value);
  }
  printf("]\n");
}
