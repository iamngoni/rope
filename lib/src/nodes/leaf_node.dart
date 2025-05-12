//
//  rope
//  leaf_node.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'internal_node.dart';
import 'rope_node.dart';

/// A leaf node that contains actual string content.
class LeafNode extends RopeNode {
  final String text;

  /// Creates a leaf node with the given string.
  LeafNode(this.text);

  @override
  int get length => text.length;

  @override
  String flatten() => text;

  @override
  RopeNode insert(int index, String newText) {
    final left = text.substring(0, index);
    final right = text.substring(index);
    return InternalNode(
      LeafNode(left),
      InternalNode(LeafNode(newText), LeafNode(right)),
    );
  }

  @override
  String substring(int start, int end) => text.substring(start, end);

  @override
  RopeNode delete(int start, int end) {
    final left = text.substring(0, start);
    final right = text.substring(end);
    return LeafNode(left + right);
  }

  @override
  String charAt(int index) => text[index];

  @override
  (RopeNode, RopeNode) split(int index) => (
    LeafNode(text.substring(0, index)),
    LeafNode(text.substring(index)),
  );

  @override
  RopeNode concat(RopeNode other) => InternalNode(this, other).rebalance();
}
