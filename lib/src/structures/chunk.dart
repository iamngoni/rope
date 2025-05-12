//
//  rope
//  chunk.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'text_summary.dart';

/// A chunk of text stored as a leaf node in the rope data structure.
///
/// The [Chunk] class represents the fundamental unit of text storage in the rope.
/// Each chunk contains a continuous string of text and provides methods for
/// manipulating and accessing that text. Chunks are stored in leaf nodes
/// of the rope's tree structure.
class Chunk {
  /// Constructs a [Chunk] from the provided [text].
  ///
  /// The text string should be of reasonable size for optimal rope performance.
  /// Too small chunks increase tree overhead, while too large chunks reduce
  /// the benefits of the rope structure.
  const Chunk(this.text);

  /// The raw text content stored in this chunk.
  final String text;

  /// Returns a [TextSummary] representing the metadata of this chunk.
  ///
  /// The summary contains the length of the text and the number of newline
  /// characters, which are used for efficient navigation and operations
  /// in the rope structure.
  TextSummary get summary => TextSummary(
        text.length,
        '\n'.allMatches(text).length,
      );

  /// Gets a substring from this chunk.
  ///
  /// [start] is the starting index (inclusive).
  /// [end] is the ending index (exclusive).
  ///
  /// Returns the substring from [start] to [end].
  /// Throws [RangeError] if [start] or [end] is out of bounds.
  String substring(int start, int end) => text.substring(start, end);

  /// Splits the chunk at [index] into two chunks.
  ///
  /// This operation is used during rope editing operations like insertion
  /// and deletion to maintain the tree structure.
  ///
  /// The [index] is the position at which to split the text.
  ///
  /// Returns a tuple containing the left and right chunks after splitting.
  /// Throws [RangeError] if [index] is out of bounds.
  (Chunk, Chunk) split(int index) =>
      (Chunk(text.substring(0, index)), Chunk(text.substring(index)));

  /// Returns the character at the specified [index].
  ///
  /// The [index] is the position of the character to retrieve.
  ///
  /// Returns the character at [index].
  /// Throws [RangeError] if [index] is out of bounds.
  String charAt(int index) => text[index];
}
