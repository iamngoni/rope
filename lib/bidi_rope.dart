/// A bidirectional text-aware extension to the Rope data structure.
///
/// This library provides bidirectional text support for the existing Rope
/// implementation, adding proper handling of mixed left-to-right (LTR) and
/// right-to-left (RTL) text common in languages like Arabic, Hebrew, and Persian.
library bidi_rope;

export 'src/unicode/bidirectional.dart';
export 'src/unicode/bidi_rope.dart';
export 'src/unicode/line_breaking.dart';