//
//  rope
//  text_summary.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

import 'summary.dart';

/// A summary of text data within a chunk in the rope data structure.
///
/// This class implements the [Summary] interface and is used to track metadata
/// about text chunks within the rope. It maintains two key metrics:
/// - [length]: The number of UTF-16 code units (characters) in the text
/// - [lines]: The number of newline characters, which is used for line counting
///
/// This summary enables efficient operations on the rope structure without
/// having to traverse the entire text content.
class TextSummary implements Summary {
  /// Constructs a new [TextSummary] with the given [length] and [lines].
  ///
  /// [length] is the number of characters in the text chunk.
  /// [lines] is the number of newline characters in the text chunk.
  const TextSummary(this.length, this.lines);

  /// The number of characters (UTF-16 code units) in the text.
  final int length;
  
  /// The number of newline characters in the text.
  /// Used for line-based calculations and operations.
  final int lines;

  /// Combines this summary with another to produce a new summary.
  ///
  /// This is used when concatenating text chunks or when calculating
  /// the summary of a parent node from its children in the rope structure.
  ///
  /// The [other] summary must be a [TextSummary]. Throws a [TypeError]
  /// if [other] is not a [TextSummary].
  ///
  /// Returns a new [TextSummary] with combined length and line counts.
  @override
  TextSummary add(Summary other) {
    final o = other as TextSummary;
    return TextSummary(length + o.length, lines + o.lines);
  }

  /// A constant representing an empty text summary.
  ///
  /// Useful as an initial value for summary calculations and for representing
  /// empty text chunks.
  static const empty = TextSummary(0, 0);
}
