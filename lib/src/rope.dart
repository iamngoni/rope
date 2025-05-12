//
//  rope
//  rope.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'nodes/nodes.dart';

/// Utility class to interact with the Rope structure.
class Rope {
  final RopeNode root;

  Rope._(this.root);

  /// Creates a new Rope from the given string.
  factory Rope.fromString(String text) => Rope._(LeafNode(text));

  /// Inserts [text] at the given [index].
  Rope insert(int index, String text) => Rope._(root.insert(index, text));

  /// Returns a substring from [start] to [end] (exclusive).
  String substring(int start, int end) => root.substring(start, end);

  /// Returns the complete string.
  @override
  String toString() => root.flatten();
}
