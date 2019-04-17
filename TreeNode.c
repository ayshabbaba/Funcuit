#include <stdio.h>
#include "TreeNode.h"
#include <stdbool.h>

bool hasChildren(TreeNode n)
{
  return (n.totalChildren > 0);
}

//assumes that totalChildren will always be capped at 100
void addChildNode(TreeNode root, TreeNode child)
{
  if (root.totalChildren < 100)
  {
    root.children[root.totalChildren] = *((TreeNodePointer *) &child);
    root.totalChildren += 1;
  }
}

void addChildChar(TreeNode root, char charValue)
{
  TreeNode temp;
  temp.value = charValue;
  temp.totalChildren = 0;

  if (root.totalChildren < 100)
  {
    root.children[root.totalChildren] = *((TreeNodePointer *) &temp);
    root.totalChildren += 1;
  }
}
