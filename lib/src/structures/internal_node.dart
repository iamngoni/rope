//
//  rope
//  internal_node.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'structures.dart';

/// An internal node in the rope data structure that contains child nodes.
///
/// The [InternalNode] represents non-leaf nodes in the rope's tree structure.
/// Each internal node maintains a list of child nodes and their aggregated summaries,
/// which enables efficient navigation and operations on the text without requiring
/// full traversal.
///
/// Unlike a traditional binary rope implementation that only has left and right children,
/// this implementation allows for multiple children, which can improve balance and performance
/// in certain scenarios.
class InternalNode<T extends Chunk> extends SumTreeNode<T> {
  /// Constructs an [InternalNode] from a list of child nodes.
  ///
  /// The constructor calculates:
  /// - Individual summaries for each child node
  /// - The combined summary for the entire subtree by aggregating all child summaries
  ///
  /// The [children] parameter is the list of child nodes to store in this internal node.
  InternalNode(this.children)
      : childSummaries = children.map((c) => c.summary).toList(),
        summary = children
            .map((c) => c.summary)
            .fold(TextSummary.empty, (acc, s) => acc.add(s));

  /// The list of child nodes stored in this internal node.
  final List<SumTreeNode<T>> children;

  /// Pre-computed summaries for each individual child node.
  /// This allows for faster access to metadata without recalculation.
  final List<Summary> childSummaries;

  /// The combined summary for all children in this subtree.
  /// This enables efficient operations on the entire subtree.
  @override
  final Summary summary;

  /// Flattens all text in this node and its children into a single string.
  ///
  /// This recursively flattens all child nodes and concatenates their text.
  /// For large trees, this operation can be expensive.
  ///
  /// Returns the concatenated text of the entire subtree.
  @override
  String flatten() => children.map((c) => c.flatten()).join();

  /// Finds the index of the child node containing the specified character position.
  ///
  /// This method uses the summary information to quickly locate which child
  /// contains a given character position without traversing the entire subtree.
  ///
  /// The [index] parameter is the character position to locate.
  ///
  /// Returns the index of the child node containing that position.
  int _childIndexForOffset(int index) {
    int curr = 0;
    for (int i = 0; i < children.length; i++) {
      final len = (children[i].summary as TextSummary).length;
      if (index < curr + len) return i;
      curr += len;
    }
    return children.length - 1;
  }

  /// Splits this internal node at the specified character index.
  ///
  /// This operation:
  /// 1. Locates the child node containing the split point
  /// 2. Recursively splits that child node
  /// 3. Creates two new internal nodes: one with all content before the split point,
  ///    and one with all content from the split point onward
  ///
  /// The [index] parameter is the character position at which to split.
  ///
  /// Returns a tuple of two nodes representing the split result.
  @override
  (SumTreeNode<T>, SumTreeNode<T>) split(int index) {
    int curr = 0;
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final len = (child.summary as TextSummary).length;
      if (curr + len > index) {
        final (leftSplit, rightSplit) = child.split(index - curr);
        return (
          InternalNode([...children.sublist(0, i), leftSplit]),
          InternalNode([rightSplit, ...children.sublist(i + 1)])
        );
      }
      curr += len;
    }
    return (InternalNode(children), InternalNode([]));
  }

  /// Inserts a new item at the specified character index.
  ///
  /// This operation:
  /// 1. Locates the child node containing the insertion point
  /// 2. Recursively inserts the item in that child
  /// 3. Creates a new internal node with the updated child
  ///
  /// The [index] parameter is the character position at which to insert the item.
  /// The [item] parameter is the chunk to insert.
  ///
  /// Returns a new node containing the result of the insertion.
  @override
  SumTreeNode<T> insert(int index, T item) {
    final i = _childIndexForOffset(index);
    final updated = children[i].insert(index, item);
    return InternalNode(
        [...children.sublist(0, i), updated, ...children.sublist(i + 1)]);
  }

  /// Deletes text between the specified character indices.
  ///
  /// This operation uses the split operation to:
  /// 1. Split the node at the start position
  /// 2. Split the right portion at (end - start)
  /// 3. Discard the middle portion containing the text to delete
  /// 4. Return a new internal node with the remaining parts
  ///
  /// The [start] parameter is the starting index of the deletion (inclusive).
  /// The [end] parameter is the ending index of the deletion (exclusive).
  ///
  /// Returns a new node containing the result of the deletion.
  @override
  SumTreeNode<T> delete(int start, int end) {
    final (left, rest) = split(start);
    final (_, right) = rest.split(end - start);
    return InternalNode([left, right]);
  }

  /// Retrieves the chunk containing the specified character index.
  ///
  /// This method locates the child containing the given character position
  /// and delegates the lookup to that child.
  ///
  /// The [index] parameter is the character position to search for.
  ///
  /// Returns the chunk containing that position, or null if the index is out of bounds.
  @override
  T? itemAt(int index) {
    int offset = 0;
    for (final child in children) {
      final childLen = (child.summary as TextSummary).length;
      if (index < offset + childLen) {
        return child.itemAt(index - offset);
      }
      offset += childLen;
    }
    return null;
  }

  /// Returns the character at the specified index.
  ///
  /// This method locates the child containing the given character position
  /// and delegates to that child's charAt method.
  ///
  /// The [index] parameter is the character position to retrieve.
  ///
  /// Returns the character at that position.
  /// Throws [RangeError] if the index is out of bounds.
  @override
  String charAt(int index) {
    final i = _childIndexForOffset(index);
    return children[i].charAt(index);
  }

  /// Returns a substring between the specified character indices.
  ///
  /// This implementation uses the split operation to extract the relevant
  /// portion of the text and then flattens it.
  ///
  /// The [start] parameter is the starting index (inclusive).
  /// The [end] parameter is the ending index (exclusive).
  ///
  /// Returns the substring from start to end.
  @override
  String substring(int start, int end) {
    final (left, right) = split(end);
    final (_, sub) = left.split(start);
    return sub.flatten();
  }
}
