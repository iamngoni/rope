//
//  rope
//  rope_node.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

abstract class RopeNode {
  /// Returns the total number of characters in this node (and its children).
  int get length;

  /// Returns the full string represented by this node.
  String flatten();

  /// Inserts [text] at the specified [index] within this node.
  RopeNode insert(int index, String text);

  /// Returns a substring of the rope from [start] to [end] (exclusive).
  String substring(int start, int end);

  /// Deletes the substring from [start] to [end] (exclusive) and returns the
  ///  updated RopeNode.
  RopeNode delete(int start, int end);

  /// Returns the character at the specified [index].
  String charAt(int index);

  /// Splits the rope into two RopeNodes at the given [index].
  /// Returns a tuple of the left and right parts.
  (RopeNode, RopeNode) split(int index);

  /// Concatenates this RopeNode with [other] and returns the result.
  RopeNode concat(RopeNode other);
}
