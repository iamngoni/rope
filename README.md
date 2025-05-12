# Rope Dart

A fast, immutable rope data structure in Dart using a SumTree architecture.
Inspired by Zed's implementation, this rope is optimized for large-scale string manipulation and editor-like use cases.
Supports bidirectional text handling for mixed LTR/RTL content (Arabic, Hebrew, Persian, etc).

---

Developed with 💙 by [Ngonidzashe Mangudya](https://twitter.com/iamngoni_)

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

---

## 🔧 Features

- **SumTree-based architecture** with node-level summaries
- Efficient `insert`, `delete`, `split`, `concat`, `substring`, `charAt`
- Multi-line and character-aware summaries (`TextSummary`)
- **Bidirectional text support** for languages with right-to-left scripts
- Designed for speed, immutability, and extensibility

## 📦 Installation

```yaml
dependencies:
  rope:
    git:
      url: https://github.com/iamngoni/rope.git
```

Or

```yaml
dependencies:
  rope: <version>
```

## 🧱 What is a Rope?

A **rope** is a tree-based data structure for storing and editing large strings efficiently. Zed uses a generalized B+ tree called a **SumTree**, where each node summarizes its subtree (e.g., character length, line count).

This enables:
- O(log n) character access and mutation
- Efficient line/column ↔ offset conversion
- Concurrent snapshotting & persistence

## 🛠 Example Usage

```dart
void main() {
  final rope = Rope.fromString("Hello World!");

  final inserted = rope.insert(5, ", beautiful");
  print(inserted); // Hello, beautiful World!

  final deleted = inserted.delete(5, 16);
  print(deleted); // Hello World!

  final char = rope.charAt(1);
  print(char); // e

  final substring = rope.substring(0, 5);
  print(substring); // Hello

  final (left, right) = rope.split(6);
  print(left);  // Hello
  print(right); // World!
}
```

### Bidirectional Text Support

```dart
void main() {
  // Create a bidirectional rope with mixed LTR/RTL content
  final bidiRope = BidiRope.fromString("Hello שלום");
  
  // Check if the rope contains RTL text
  print(bidiRope.containsRtl); // true
  
  // Check if the rope is primarily RTL 
  print(bidiRope.isRtl); // false
  
  // Find all RTL segments (start/end indices)
  final segments = bidiRope.getRtlSegments(); 
  print(segments); // [[6, 10]]
  
  // Add Unicode control characters for proper display
  print(bidiRope.toStringWithControls());
  
  // Convert back to regular rope if needed
  final regularRope = bidiRope.toRope();
}
```

## 🧪 Running Tests

Use the `test` package:

```bash
dart test
```

## 🧠 Internals

Each rope is a SumTree of `Chunk` nodes:

```dart
class Rope {
  final SumTreeNode<Chunk> root;
}
```

Each node maintains a `TextSummary`:
```dart
class TextSummary {
  final int length;
  final int lines;
}
```

The `BidiRope` class extends the functionality with bidirectional text awareness:
```dart
class BidiRope {
  final Rope _rope;
  final bool _containsRtl;
  
  // Methods for bidirectional text handling
}
```

This allows efficient traversal and slicing of large text structures, with proper handling of mixed LTR/RTL content following the Unicode Bidirectional Algorithm.

## 📄 License

[MIT](./LICENSE). Based on concepts in [Zed's Rope & SumTree](https://zed.dev/blog/zed-decoded-rope-sumtree).

---
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
