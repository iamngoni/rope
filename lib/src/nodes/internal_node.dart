//
//  rope
//  internal_node.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'leaf_node.dart';
import 'rope_node.dart';

/// An internal node that joins two RopeNodes (left and right).
///
/// The `weight` is the total number of characters in the left subtree.
class InternalNode extends RopeNode {
  final RopeNode left;
  final RopeNode right;
  final int weight;

  /// Creates an internal node and computes the weight from the left node.
  InternalNode(this.left, this.right) : weight = left.length;

  @override
  int get length => left.length + right.length;

  @override
  String flatten() => left.flatten() + right.flatten();

  @override
  RopeNode insert(int index, String newText) {
    if (index < weight) {
      return InternalNode(left.insert(index, newText), right);
    } else {
      return InternalNode(left, right.insert(index - weight, newText));
    }
  }

  @override
  String substring(int start, int end) {
    if (end <= weight) {
      return left.substring(start, end);
    } else if (start >= weight) {
      return right.substring(start - weight, end - weight);
    } else {
      final leftPart = left.substring(start, weight);
      final rightPart = right.substring(0, end - weight);
      return leftPart + rightPart;
    }
  }

  @override
  RopeNode delete(int start, int end) {
    if (end <= weight) {
      return InternalNode(left.delete(start, end), right).rebalance();
    } else if (start >= weight) {
      return InternalNode(
        left,
        right.delete(start - weight, end - weight),
      ).rebalance();
    } else {
      final leftDel = left.delete(start, weight);
      final rightDel = right.delete(0, end - weight);
      return InternalNode(leftDel, rightDel).rebalance();
    }
  }

  @override
  String charAt(int index) {
    if (index < weight) {
      return left.charAt(index);
    } else {
      return right.charAt(index - weight);
    }
  }

  @override
  (RopeNode, RopeNode) split(int index) {
    if (index < weight) {
      final (leftSplit, rightSplit) = left.split(index);
      return (leftSplit, InternalNode(rightSplit, right).rebalance());
    } else {
      final (leftSplit, rightSplit) = right.split(index - weight);
      return (InternalNode(left, leftSplit).rebalance(), rightSplit);
    }
  }

  @override
  RopeNode concat(RopeNode other) => InternalNode(this, other).rebalance();

  /// Rebalances the tree to maintain performance
  RopeNode rebalance() {
    if (left is InternalNode && right is InternalNode) return this;
    if (left is LeafNode && right is LeafNode) return this;

    final flat = flatten();
    return _buildBalanced(flat);
  }

  RopeNode _buildBalanced(String text) {
    if (text.length <= 10) return LeafNode(text);
    final mid = text.length ~/ 2;
    return InternalNode(
      _buildBalanced(text.substring(0, mid)),
      _buildBalanced(text.substring(mid)),
    );
  }
}
