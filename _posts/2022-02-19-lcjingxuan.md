---
title: 
categories:
  - 
tags:
  - 
  - 
---

# 二叉树与链表

**二叉树和链表题**一直是我的难点：

展开为链表比较简单，只需要左右子树递归：

114（展开为先序遍历） 剑指offer36（展开为中序遍历）

链表转为二叉树比较难的。

**例：109** 
>给定一个单链表，其中的元素按升序排序，将其转换为高度平衡的二叉搜索树。
本题中，一个高度平衡二叉树是指一个二叉树每个节点 的左右两个子树的高度差的绝对值不超过 1。

这个技巧是每次都找最中间那个节点作为根。链表找中点就得用快慢指针了。

找完中点之后就递归。这里可以把mid节点前面的edge切掉，后面的edge也切掉，再分别在左右两个头上递归。like this.

![binary1](/Users/apple/yuhengfdada.github.io/assets/lcjx/binary1.png)

切后面好做，mid->next保存下来然后让mid->next = nullptr.

切前面的话得从头再遍历到mid之前的那个节点。我封装了一个cutBefore()函数。

至于正确性证明，只要证明“**节点数最多相差1的两个子树，其高度最多相差1**”就可以了。

# BST删除

过于经典，从61b开始已经写了n遍了还是反应不过来。爷佛了。

每次都走到死胡同，**错误解法**：

假设找到左子树最大节点。findMax(u->left)，然后把自己的值替换为该节点的值。再递归地从左子树中删掉那个节点。这个方法的问题是：无法定位toDelete节点的**父亲**。如果toDelete节点是叶子的话就很jb麻烦。太烦了！

**正确解法：利用递归返回值**

给我记住。sb。

```cpp
class Solution {
public:
    TreeNode* deleteNode(TreeNode* root, int key) 
    {
        if (root == nullptr)    return nullptr;
        if (key > root->val)    root->right = deleteNode(root->right, key);     // 去右子树删除
        else if (key < root->val)    root->left = deleteNode(root->left, key);  // 去左子树删除
        else    // 当前节点就是要删除的节点
        {
            if (! root->left)   return root->right; // 情况1，欲删除节点无左子
            if (! root->right)  return root->left;  // 情况2，欲删除节点无右子
            TreeNode* node = root->right;           // 情况3，欲删除节点左右子都有 
            while (node->left)          // 寻找欲删除节点右子树的最左节点
                node = node->left;
            node->left = root->left;    // 将欲删除节点的左子树成为其右子树的最左节点的左子树
            root = root->right;         // 欲删除节点的右子顶替其位置，节点被删除
        }
        return root;    
    }
};
```





