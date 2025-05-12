/// Rope data structure library for efficient text manipulation.
///
/// A rope is a data structure that is used to efficiently store and manipulate
/// very large strings. Ropes enable efficient insertion, deletion, and
/// concatenation operations by representing text as a balanced tree of chunks,
/// rather than a single contiguous array of characters.
///
/// This implementation provides a high-level [Rope] class for easy usage,
/// as well as the underlying tree structure components for advanced use cases.
library rope;

export 'src/rope.dart';
export 'src/structures/structures.dart';
