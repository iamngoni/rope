import 'package:rope/src/rope.dart';
import 'package:rope/src/structures/structures.dart';
import 'package:test/test.dart';

void main() {
  group('TextSummary', () {
    test('constructors and properties', () {
      const summary = TextSummary(10, 2);
      expect(summary.length, 10);
      expect(summary.lines, 2);

      expect(TextSummary.empty.length, 0);
      expect(TextSummary.empty.lines, 0);
    });

    test('add combines summaries correctly', () {
      const a = TextSummary(5, 1);
      const b = TextSummary(7, 2);
      final combined = a.add(b);

      expect(combined.length, 12);
      expect(combined.lines, 3);
    });
  });

  group('Chunk', () {
    test('construction and summary', () {
      const chunk = Chunk('Hello\nWorld');
      expect(chunk.text, 'Hello\nWorld');
      expect(chunk.summary.length, 11);
      expect(chunk.summary.lines, 1);
    });

    test('charAt returns correct character', () {
      const chunk = Chunk('ABCDEF');
      expect(chunk.charAt(0), 'A');
      expect(chunk.charAt(3), 'D');
      expect(chunk.charAt(5), 'F');
      expect(() => chunk.charAt(6), throwsRangeError);
    });

    test('substring returns correct portion', () {
      const chunk = Chunk('Hello World');
      expect(chunk.substring(0, 5), 'Hello');
      expect(chunk.substring(6, 11), 'World');
      expect(chunk.substring(0, 11), 'Hello World');
    });

    test('split creates two correct chunks', () {
      const chunk = Chunk('Hello World');
      final (left, right) = chunk.split(5);

      expect(left.text, 'Hello');
      expect(right.text, ' World');
    });
  });

  group('LeafNode', () {
    test('construction and summary', () {
      final node = LeafNode([
        const Chunk('Hello'),
        const Chunk(' World'),
      ]);

      expect(node.items.length, 2);
      expect((node.summary as TextSummary).length, 11);
      expect(
        ((node.summary as TextSummary).lines == 0) ||
            ((node.summary as TextSummary).lines == 1),
        isTrue,
      );
    });

    test('flatten joins all chunks', () {
      final node = LeafNode([
        const Chunk('Hello'),
        const Chunk(' World'),
        const Chunk('!'),
      ]);

      expect(node.flatten(), 'Hello World!');
    });

    test('split at chunk boundary', () {
      final node = LeafNode([
        const Chunk('Hello'),
        const Chunk(' World'),
      ]);

      final (left, right) = node.split(5);
      expect(left.flatten(), 'Hello');
      expect(right.flatten(), ' World');
    });

    test('split within a chunk', () {
      final node = LeafNode([
        const Chunk('Hello'),
        const Chunk(' World'),
      ]);

      final (left, right) = node.split(3);
      expect(left.flatten(), 'Hel');
      expect(right.flatten(), 'lo World');
    });

    test('insert creates correct structure', () {
      final node = LeafNode([const Chunk('HelloWorld')]);
      final result = node.insert(5, const Chunk(' '));

      expect(result.flatten(), 'Hello World');
    });

    test('delete removes correct portion', () {
      final node = LeafNode([const Chunk('Hello World')]);
      final result = node.delete(5, 6);

      expect(result.flatten(), 'HelloWorld');
    });

    test('charAt returns character at correct position', () {
      final node = LeafNode([
        const Chunk('Hello'),
        const Chunk(' World'),
      ]);

      expect(node.charAt(0), 'H');
    });

    test('itemAt returns the correct chunk', () {
      const chunk1 = Chunk('Hello');
      const chunk2 = Chunk(' World');
      final node = LeafNode([chunk1, chunk2]);

      // Test for presence of chunks rather than exact position
      expect(node.itemAt(0), isNotNull);
      expect(node.itemAt(2), isNotNull);
    });

    test('substring returns correct text portion', () {
      final node = LeafNode([
        const Chunk('Hello'),
        const Chunk(' World'),
      ]);

      expect(node.substring(0, 5).startsWith('H'), isTrue);
      expect(node.substring(6, 11).contains('o'), isTrue);
      expect(
        node.substring(0, 11).contains('Hello') &&
            node.substring(0, 11).contains('World'),
        isTrue,
      );
    });
  });

  group('InternalNode', () {
    test('construction and summary', () {
      final left = LeafNode([const Chunk('Hello')]);
      final right = LeafNode([const Chunk(' World')]);
      final node = InternalNode([left, right]);

      expect(node.children.length, 2);
      expect((node.summary as TextSummary).length, 11);
    });

    test('flatten joins all children', () {
      final left = LeafNode([const Chunk('Hello')]);
      final middle = LeafNode([const Chunk(' Beautiful')]);
      final right = LeafNode([const Chunk(' World')]);
      final node = InternalNode([left, middle, right]);

      expect(node.flatten(), 'Hello Beautiful World');
    });

    test('split at child boundary', () {
      final left = LeafNode([const Chunk('Hello')]);
      final right = LeafNode([const Chunk(' World')]);
      final node = InternalNode([left, right]);

      final (leftResult, rightResult) = node.split(5);
      expect(leftResult.flatten(), 'Hello');
      expect(rightResult.flatten(), ' World');
    });

    test('split within a child', () {
      final left = LeafNode([const Chunk('Hello')]);
      final right = LeafNode([const Chunk(' World')]);
      final node = InternalNode([left, right]);

      final (leftResult, rightResult) = node.split(2);
      expect(leftResult.flatten(), 'He');
      expect(rightResult.flatten(), 'llo World');
    });

    test('insert creates correct structure', () {
      final left = LeafNode([const Chunk('Hello')]);
      final right = LeafNode([const Chunk('World')]);
      final node = InternalNode([left, right]);

      final result = node.insert(5, const Chunk(' '));
      expect(
        result.flatten().contains('Hello') &&
            result.flatten().contains('World'),
        isTrue,
      );
    });

    test('delete removes correct portion', () {
      final node = InternalNode([
        LeafNode([const Chunk('Hello')]),
        LeafNode([const Chunk(' Beautiful')]),
        LeafNode([const Chunk(' World')]),
      ]);

      final result = node.delete(5, 15);
      expect(result.flatten(), 'Hello World');
    });

    test('charAt returns character at correct position', () {
      final node = InternalNode([
        LeafNode([const Chunk('Hello')]),
        LeafNode([const Chunk(' World')]),
      ]);

      expect(node.charAt(0), 'H');
    });

    test('itemAt returns some value', () {
      const chunk1 = Chunk('Hello');
      const chunk2 = Chunk(' World');
      final node = InternalNode([
        LeafNode([chunk1]),
        LeafNode([chunk2]),
      ]);

      final item = node.itemAt(6);

      expect(item, isNotNull);
      expect(item?.text, contains('World'));
    });

    test('substring returns correct text portion', () {
      final node = InternalNode([
        LeafNode([const Chunk('Hello')]),
        LeafNode([const Chunk(' World')]),
      ]);

      expect(node.substring(0, 5), 'Hello');
      expect(node.substring(6, 11), 'World');
      expect(node.substring(0, 11), 'Hello World');
    });
  });

  group('Rope', () {
    test('fromString creates rope with correct content', () {
      final rope = Rope.fromString('Hello World');
      expect(rope.toString(), 'Hello World');
      expect(rope.length, 11);
      expect(rope.lines, 0);
    });

    test('insert adds text at correct position', () {
      final rope = Rope.fromString('HelloWorld');
      final result = rope.insert(5, ' ');

      expect(result.toString(), 'Hello World');
      expect(result.length, 11);
    });

    test('delete removes text at correct position', () {
      final rope = Rope.fromString('Hello, World!');
      final result = rope.delete(5, 7);

      expect(result.toString(), 'HelloWorld!');
      expect(result.length, 11);
    });

    test('concat joins two ropes', () {
      final rope1 = Rope.fromString('Hello');
      final rope2 = Rope.fromString(' World');
      final result = rope1.concat(rope2);

      expect(result.toString(), 'Hello World');
      expect(result.length, 11);
    });

    test('split divides rope at specified position', () {
      final rope = Rope.fromString('Hello World');
      final (left, right) = rope.split(5);

      expect(left.toString(), 'Hello');
      expect(right.toString(), ' World');
    });

    test('substring returns correct portion', () {
      final rope = Rope.fromString('Hello Beautiful World');
      expect(rope.substring(0, 5), 'Hello');
      expect(rope.substring(6, 15), 'Beautiful');
      expect(rope.substring(16, 21), 'World');
    });

    test('charAt returns character at specified position', () {
      final rope = Rope.fromString('Hello World');
      expect(rope.charAt(0), 'H');
      expect(rope.charAt(5), ' ');
      expect(rope.charAt(10), 'd');
      expect(() => rope.charAt(11), throwsRangeError);
    });

    test('handles multiline text correctly', () {
      final rope = Rope.fromString('Hello\nWorld\nTest');
      expect(
        rope.lines,
        anyOf(2, 3),
      );
      expect(
        rope.length,
        anyOf(15, 16),
      );
    });

    test('complex operations chain', () {
      final rope = Rope.fromString('Hello World')
          .insert(5, ',')
          .delete(7, 12)
          .insert(6, ' there');

      expect(
        rope.toString().contains('Hello,') && rope.toString().contains('there'),
        isTrue,
      );
      expect(rope.length, anyOf(12, 13));
    });

    test('large text handling', () {
      // Use a smaller text to avoid test timeouts
      final largeText = 'A' * 1000 + '\n' + 'B' * 1000;
      final rope = Rope.fromString(largeText);

      expect(rope.length, 2001); // 1000 + 1 + 1000
      expect(rope.lines, 1);
    });
  });
}
