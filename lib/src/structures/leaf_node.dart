//
//  rope
//  leaf_node.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'chunk.dart';
import 'internal_node.dart';
import 'sum_tree_node.dart';
import 'summary.dart';
import 'text_summary.dart';

/// A leaf node in the rope data structure that contains a list of text chunks.
///
/// The [LeafNode] class represents the bottom level of the rope tree. It stores
/// the actual text content as a list of chunk items, along with their summaries.
/// This implementation enables efficient text operations by maintaining metadata
/// about the text without requiring full traversal.
///
/// Leaf nodes are designed to be immutable - operations return new nodes rather
/// than modifying existing ones, which facilitates persistent data structures.
class LeafNode<T extends Chunk> extends SumTreeNode<T> {
  /// Constructs a [LeafNode] from a list of chunk items.
  ///
  /// The constructor calculates:
  /// - Individual summaries for each item
  /// - The combined summary for the entire node by aggregating all item summaries
  ///
  /// The [items] parameter is the list of text chunks to store in this leaf node.
  LeafNode(this.items)
      : summaries = items.map((item) => item.summary).toList(),
        summary = items
            .map((item) => item.summary)
            .fold(TextSummary.empty, (acc, s) => acc.add(s));

  /// The list of text chunks stored in this leaf node.
  final List<T> items;
  
  /// Pre-computed summaries for each individual chunk item.
  /// This allows for faster access to metadata without recalculation.
  final List<Summary> summaries;
  
  /// The combined summary for all items in this node.
  /// This enables efficient operations on the entire subtree.
  @override
  final Summary summary;

  /// Flattens all text chunks in this node into a single string.
  ///
  /// Returns the concatenated text of all chunks in this leaf node.
  @override
  String flatten() => items.map((c) => c.text).join();

  /// Splits this leaf node at the specified character index.
  ///
  /// This operation finds the chunk containing the split point, splits that chunk,
  /// and then creates two new leaf nodes: one with all content before the split point,
  /// and one with all content from the split point onward.
  ///
  /// The [index] parameter is the character position at which to split.
  ///
  /// Returns a tuple of two nodes representing the split result.
  @override
  (SumTreeNode<T>, SumTreeNode<T>) split(int index) {
    int currOffset = 0;
    for (int i = 0; i < items.length; i++) {
      final len = items[i].text.length;
      if (currOffset + len > index) {
        final (leftChunk, rightChunk) = items[i].split(index - currOffset);
        return (
          LeafNode([...items.sublist(0, i), leftChunk as T]),
          LeafNode([rightChunk as T, ...items.sublist(i + 1)])
        );
      }
      currOffset += len;
    }
    return (LeafNode(items), LeafNode([]));
  }

  /// Inserts a new item at the specified character index.
  ///
  /// This operation:
  /// 1. Splits the node at the insertion point
  /// 2. Creates a new leaf node containing only the inserted item
  /// 3. Returns a new internal node containing the left split, the new item, and the right split
  ///
  /// The [index] parameter is the character position at which to insert the item.
  /// The [item] parameter is the chunk to insert.
  ///
  /// Returns a new node containing the result of the insertion.
  @override
  SumTreeNode<T> insert(int index, T item) {
    final (left, right) = split(index);
    return InternalNode<T>([
      left,
      LeafNode([item]),
      right,
    ]);
  }

  /// Deletes text between the specified character indices.
  ///
  /// This operation:
  /// 1. Splits the node at the start position
  /// 2. Splits the right portion at (end - start)
  /// 3. Discards the middle portion containing the text to delete
  /// 4. Returns a new internal node with the remaining parts
  ///
  /// The [start] parameter is the starting index of the deletion (inclusive).
  /// The [end] parameter is the ending index of the deletion (exclusive).
  ///
  /// Returns a new node containing the result of the deletion.
  @override
  SumTreeNode<T> delete(int start, int end) {
    final (left, rest) = split(start);
    final (_, right) = rest.split(end - start);
    return InternalNode<T>([left, right]);
  }

  /// Retrieves the chunk containing the specified character index.
  ///
  /// This method traverses the chunks in this leaf node to find which
  /// chunk contains the given character position.
  ///
  /// The [index] parameter is the character position to search for.
  ///
  /// Returns the chunk containing that position, or null if the index is out of bounds.
  @override
  T? itemAt(int index) {
    int currOffset = 0;
    for (final item in items) {
      if (index < currOffset + item.text.length) return item;
      currOffset += item.text.length;
    }
    return null;
  }

  /// Returns the character at the specified index.
  ///
  /// This method locates the chunk containing the character at the given position
  /// and delegates to that chunk's charAt method.
  ///
  /// The [index] parameter is the character position to retrieve.
  ///
  /// Returns the character at that position.
  /// Throws [RangeError] if the index is out of bounds.
  @override
  String charAt(int index) {
    int currOffset = 0;
    for (final item in items) {
      if (index < currOffset + item.text.length) {
        return item.charAt(index - currOffset);
      }
      currOffset += item.text.length;
    }
    throw RangeError('Index out of range');
  }

  /// Returns a substring between the specified character indices.
  ///
  /// This implementation flattens the entire node and then extracts the substring.
  /// For large nodes, this can be inefficient compared to a specialized implementation
  /// that only extracts the relevant portions from each chunk.
  ///
  /// The [start] parameter is the starting index (inclusive).
  /// The [end] parameter is the ending index (exclusive).
  ///
  /// Returns the substring from start to end.
  @override
  String substring(int start, int end) {
    return flatten().substring(start, end);
  }
}
