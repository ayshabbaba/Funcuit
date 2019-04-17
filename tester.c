#include <stdio.h>
#include <string.h>
#include "TreeNode.h"

int main(void) {
  TreeNode root;

  root.value = '+';
  root.totalChildren = 0;

  addChildChar((&root), '*');
  addChildChar((&root), 'A');
  addChildChar((&root), '*');

  printTreeStacked(root);
}
