import 'package:rope/bidi_rope.dart';
import 'package:test/test.dart';

void main() {
  group('BidirectionalText Tests', () {
    test('Detects RTL direction correctly', () {
      // Hebrew text (RTL)
      expect(BidirectionalText.isRtl('שלום'), isTrue);

      // Arabic text (RTL)
      expect(BidirectionalText.isRtl('مرحبا'), isTrue);

      // English text (LTR)
      expect(BidirectionalText.isRtl('Hello'), isFalse);

      // Mixed text starting with RTL
      expect(BidirectionalText.isRtl('שלום Hello'), isTrue);

      // Mixed text starting with LTR
      expect(BidirectionalText.isRtl('Hello שלום'), isFalse);

      // Numbers (neutral)
      expect(BidirectionalText.isRtl('12345'), isFalse);

      // Punctuation (neutral)
      expect(BidirectionalText.isRtl('!@#\$%'), isFalse);

      // Empty string
      expect(BidirectionalText.isRtl(''), isFalse);
    });

    test('Detects RTL content correctly', () {
      // Hebrew text
      expect(BidirectionalText.containsRtl('שלום'), isTrue);

      // Arabic text
      expect(BidirectionalText.containsRtl('مرحبا'), isTrue);

      // English text
      expect(BidirectionalText.containsRtl('Hello'), isFalse);

      // Mixed text
      expect(BidirectionalText.containsRtl('Hello שלום'), isTrue);

      // Numbers and punctuation
      expect(BidirectionalText.containsRtl('12345!@#\$%'), isFalse);

      // Empty string
      expect(BidirectionalText.containsRtl(''), isFalse);
    });

    test('Finds first strong directional character', () {
      // RTL first
      expect(BidirectionalText.findFirstStrongDirectional('שלום Hello'),
          equals(0));

      // LTR first
      expect(BidirectionalText.findFirstStrongDirectional('Hello שלום'),
          equals(0));

      // Neutral then RTL
      expect(
          BidirectionalText.findFirstStrongDirectional('123 שלום'), equals(4));

      // Neutral then LTR
      expect(
          BidirectionalText.findFirstStrongDirectional('123 Hello'), equals(4));

      // Only neutral
      expect(BidirectionalText.findFirstStrongDirectional('12345'), equals(-1));

      // Empty string
      expect(BidirectionalText.findFirstStrongDirectional(''), equals(-1));
    });

    test('Finds RTL segments correctly', () {
      // Single RTL segment
      final segments1 = BidirectionalText.findRtlSegments('שלום');
      expect(segments1.length, equals(1));
      expect(segments1[0][0], equals(0));
      expect(segments1[0][1], equals(4));

      // Mixed text with one RTL segment
      final segments2 = BidirectionalText.findRtlSegments('Hello שלום World');
      expect(segments2.length, equals(1));
      expect(segments2[0][0], equals(6));
      expect(segments2[0][1], equals(10));

      // Multiple RTL segments
      final segments3 =
          BidirectionalText.findRtlSegments('Hello שלום World مرحبا');
      expect(segments3.length, equals(2));

      // No RTL segments
      final segments4 = BidirectionalText.findRtlSegments('Hello World');
      expect(segments4.length, equals(0));
    });

    test('Wraps text with appropriate control characters', () {
      // RTL text
      final rtlWrapped = BidirectionalText.wrapWithControls('שלום');
      expect(rtlWrapped.codeUnitAt(0), equals(0x202B));
      expect(rtlWrapped.codeUnitAt(rtlWrapped.length - 1), equals(0x202C));

      // LTR text with RTL content
      final mixedWrapped = BidirectionalText.wrapWithControls('Hello שלום');
      expect(mixedWrapped.codeUnitAt(0), equals(0x202A));
      expect(mixedWrapped.codeUnitAt(mixedWrapped.length - 1), equals(0x202C));

      // LTR text only
      final ltrText = BidirectionalText.wrapWithControls('Hello World');
      expect(ltrText, equals('Hello World'));
    });
  });

  group('BidiRope Tests', () {
    test('Creates BidiRope correctly', () {
      // RTL text
      final rtlRope = BidiRope.fromString('שלום');
      expect(rtlRope.containsRtl, isTrue);
      expect(rtlRope.isRtl, isTrue);

      // LTR text
      final ltrRope = BidiRope.fromString('Hello');
      expect(ltrRope.containsRtl, isFalse);
      expect(ltrRope.isRtl, isFalse);

      // Mixed text
      final mixedRope = BidiRope.fromString('Hello שלום');
      expect(mixedRope.containsRtl, isTrue);
      expect(mixedRope.isRtl, isFalse);
    });

    test('Substring preserves bidirectional properties', () {
      final rope = BidiRope.fromString('Hello שלום World');

      // Substring with only LTR content
      final ltrPart = rope.substring(0, 5);
      expect(ltrPart.toString(), equals('Hello'));
      expect(ltrPart.containsRtl, isFalse);

      // Substring with only RTL content
      final rtlPart = rope.substring(6, 10);
      expect(rtlPart.toString(), equals('שלום'));
      expect(rtlPart.containsRtl, isTrue);
      expect(rtlPart.isRtl, isTrue);

      // Substring with mixed content
      final mixedPart = rope.substring(0, 10);
      expect(mixedPart.toString(), equals('Hello שלום'));
      expect(mixedPart.containsRtl, isTrue);
    });

    test('Insert handles bidirectional text correctly', () {
      // Insert RTL into LTR
      final rope1 = BidiRope.fromString('Hello World');
      final newRope1 = rope1.insert(6, 'שלום ');
      expect(newRope1.toString(), equals('Hello שלום World'));
      expect(newRope1.containsRtl, isTrue);

      // Insert LTR into RTL
      final rope2 = BidiRope.fromString('שלום');
      final newRope2 = rope2.insert(4, ' Hello');
      expect(newRope2.toString(), equals('שלום Hello'));
      expect(newRope2.containsRtl, isTrue);
    });

    test('Delete handles bidirectional text correctly', () {
      // Delete RTL part
      final rope1 = BidiRope.fromString('Hello שלום World');
      final newRope1 = rope1.delete(6, 10);
      expect(newRope1.toString(), equals('Hello  World'));
      expect(newRope1.containsRtl, isFalse);

      // Delete LTR part but keep RTL
      final rope2 = BidiRope.fromString('Hello שלום World');
      final newRope2 = rope2.delete(0, 6);
      expect(newRope2.toString(), equals('שלום World'));
      expect(newRope2.containsRtl, isTrue);
    });

    test('Concat combines ropes correctly', () {
      final ltrRope = BidiRope.fromString('Hello ');
      final rtlRope = BidiRope.fromString('שלום');

      final combined = ltrRope.concat(rtlRope);
      expect(combined.toString(), equals('Hello שלום'));
      expect(combined.containsRtl, isTrue);
    });

    test('Split divides rope correctly', () {
      final rope = BidiRope.fromString('Hello שלום World');
      final (left, right) = rope.split(6);

      expect(left.toString(), equals('Hello '));
      expect(right.toString(), equals('שלום World'));

      expect(left.containsRtl, isFalse);
      expect(right.containsRtl, isTrue);
    });

    test('Gets RTL segments correctly', () {
      // Single RTL segment
      final rope1 = BidiRope.fromString('Hello שלום World');
      final segments1 = rope1.getRtlSegments();
      expect(segments1.length, equals(1));
      expect(segments1[0][0], equals(6));
      expect(segments1[0][1], equals(10));

      // Multiple RTL segments
      final rope2 = BidiRope.fromString('Hello שלום World مرحبا');
      final segments2 = rope2.getRtlSegments();
      expect(segments2.length, equals(2));

      // No RTL segments
      final rope3 = BidiRope.fromString('Hello World');
      final segments3 = rope3.getRtlSegments();
      expect(segments3.length, equals(0));
    });

    test('Adds control characters correctly', () {
      // RTL text
      final rtlRope = BidiRope.fromString('שלום');
      final rtlWithControls = rtlRope.toStringWithControls();
      expect(rtlWithControls.codeUnitAt(0), equals(0x202B));

      // LTR text with RTL content
      final mixedRope = BidiRope.fromString('Hello שלום');
      final mixedWithControls = mixedRope.toStringWithControls();
      expect(mixedWithControls.codeUnitAt(0), equals(0x202A));

      // LTR text only
      final ltrRope = BidiRope.fromString('Hello World');
      final ltrWithControls = ltrRope.toStringWithControls();
      expect(ltrWithControls, equals('Hello World'));
    });

    test('Compatibility with original Rope', () {
      final bidiRope = BidiRope.fromString('Hello שלום World');

      final regularRope = bidiRope.toRope();

      expect(regularRope.toString(), equals('Hello שלום World'));
    });
  });
}
