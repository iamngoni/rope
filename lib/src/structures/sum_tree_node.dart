//
//  rope
//  sum_tree_node.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'summary.dart';

/// Abstract base class for all nodes in the rope data structure.
///
/// The [SumTreeNode] is the foundation of the rope's tree structure. It defines
/// the common interface that both leaf nodes and internal nodes must implement.
/// This allows the rope to maintain a balanced tree structure while providing
/// efficient text operations.
///
/// Type parameter [T] typically represents a [Chunk] or a subclass of it,
/// which contains the actual text data.
abstract class SumTreeNode<T> {
  /// Returns the summary metadata for this node and its subtree.
  ///
  /// The summary contains aggregated information like character count and
  /// line count, which enables efficient navigation and operations.
  Summary get summary;

  /// Flattens the node and all its children into a single string.
  ///
  /// This operation traverses the entire subtree and concatenates all text,
  /// which can be expensive for large trees. Use with caution.
  ///
  /// Returns the concatenated text from this node and all its descendants.
  String flatten();

  /// Splits this node at the specified character index.
  ///
  /// This operation is used during editing operations to maintain the
  /// tree structure. It returns two nodes: one containing all text before
  /// the index, and one containing all text from the index onward.
  ///
  /// The [index] specifies the character position at which to split.
  ///
  /// Returns a tuple of two nodes representing the split.
  (SumTreeNode<T>, SumTreeNode<T>) split(int index);

  /// Inserts an item at the specified character index.
  ///
  /// The [index] specifies the position at which to insert the item.
  /// The [item] is the item to insert.
  ///
  /// Returns a new node containing the result of the insertion.
  SumTreeNode<T> insert(int index, T item);

  /// Deletes text between the specified character indices.
  ///
  /// [start] is the starting index of the deletion (inclusive).
  /// [end] is the ending index of the deletion (exclusive).
  ///
  /// Returns a new node containing the result of the deletion.
  SumTreeNode<T> delete(int start, int end);

  /// Retrieves the item at the specified character index.
  ///
  /// The [index] specifies the character position to retrieve.
  ///
  /// Returns the item at that position, or null if not found.
  T? itemAt(int index);

  /// Returns the character at the specified index.
  ///
  /// The [index] specifies the character position.
  ///
  /// Returns the character at that position.
  /// Throws [RangeError] if the index is out of bounds.
  String charAt(int index);

  /// Returns a substring between the specified character indices.
  ///
  /// [start] is the starting index (inclusive).
  /// [end] is the ending index (exclusive).
  ///
  /// Returns the substring from start to end.
  String substring(int start, int end);
}
