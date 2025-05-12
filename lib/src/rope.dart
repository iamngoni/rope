//
//  rope
//  rope.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'structures/structures.dart';

/// A high-level interface representing a rope data structure for efficient
///  string manipulation.
///
/// This class provides user-friendly methods to work with an underlying rope
/// tree, allowing fast insertions, deletions, concatenations, and substring
/// operations on large texts.
/// Internally, it wraps a `RopeNode` (either a `LeafNode` or `InternalNode`)
/// to maintain a balanced tree structure.
/// A high-level interface representing a rope data structure for efficient string manipulation.
///
/// This class provides user-friendly methods to work with an underlying SumTree structure,
/// allowing fast insertions, deletions, concatenations, and substring operations on large texts.
class Rope {
  Rope._(this.root);

  factory Rope.fromString(String text) {
    final chunk = Chunk(text);
    return Rope._(LeafNode([chunk]));
  }

  final SumTreeNode<Chunk> root;

  Rope insert(int index, String text) {
    final chunk = Chunk(text);
    return Rope._(root.insert(index, chunk));
  }

  Rope delete(int start, int end) => Rope._(root.delete(start, end));

  Rope concat(Rope other) => Rope._(InternalNode([root, other.root]));

  (Rope, Rope) split(int index) {
    final (left, right) = root.split(index);
    return (Rope._(left), Rope._(right));
  }

  String substring(int start, int end) => root.substring(start, end);

  String charAt(int index) => root.charAt(index);

  int get length => (root.summary as TextSummary).length;

  int get lines => (root.summary as TextSummary).lines;

  @override
  String toString() => root.flatten();
}
