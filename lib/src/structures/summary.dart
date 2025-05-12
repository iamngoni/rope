//
//  rope
//  summary.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

/// A summary interface that defines how to combine and represent metadata
/// about a subtree in the rope data structure.
///
/// The Summary interface is a key component of the rope's efficient operations.
/// It allows the rope to maintain metadata about text segments without
/// needing to scan the entire content. This enables O(log n) performance
/// for many operations that would otherwise be O(n).
///
/// Implementations of this interface typically track metrics such as
/// character count, line count, or other properties relevant to the
/// specific application of the rope data structure.
abstract class Summary {
  /// Adds another summary to this one and returns the result.
  ///
  /// This method is used to combine summaries when:
  /// - Merging two nodes in the rope
  /// - Computing the summary of a parent node from its children
  /// - Rebalancing the tree after operations
  ///
  /// The [other] summary is the summary to combine with this one.
  ///
  /// Returns a new summary containing the combined metadata.
  Summary add(Summary other);
}
