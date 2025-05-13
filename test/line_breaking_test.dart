import 'package:rope/bidi_rope.dart';
import 'package:test/test.dart';

void main() {
  group('Line Breaking Tests', () {
    
    test('Breaks LTR text at spaces', () {
      const text = 'Hello world this is a test';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(10);
      
      expect(lines.length, equals(3));
      expect(lines[0], equals('Hello worl'));
      expect(lines[1], equals('d this is '));
      expect(lines[2], equals('a test'));
    });
    
    test('Breaks at newlines', () {
      const text = 'Hello\nworld\nthis is a test';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(20);
      
      expect(lines.length, equals(3));
      expect(lines[0], equals('Hello\n'));
      expect(lines[1], equals('world\n'));
      expect(lines[2], equals('this is a test'));
    });
    
    test('Breaks long words when necessary', () {
      const text = 'Supercalifragilisticexpialidocious';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(10);
      
      expect(lines.length, equals(4));
      expect(lines[0], equals('Supercalif'));
      expect(lines[1], equals('ragilistic'));
      expect(lines[2], equals('expialidoc'));
      expect(lines[3], equals('ious'));
    });
    
    test('Breaks after punctuation when possible', () {
      const text = 'Hello, world. This is a test.';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(15);
      
      expect(lines.length, equals(2));
      expect(lines[0], equals('Hello, world. '));
      expect(lines[1], equals('This is a test.'));
    });
    
    test('Handles RTL text correctly', () {
      const text = 'שלום עולם זהו מבחן';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(10);
      
      expect(lines.length, equals(2));
      expect(lines[0].length, lessThanOrEqualTo(10));
      expect(lines[1].length, lessThanOrEqualTo(10));
    });
    
    test('Preserves RTL segments when possible', () {
      const text = 'Hello שלום עולם world';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(15);
      
      expect(lines.length, equals(2));
      
      final bool rtlSegmentIntact = lines[0].contains('שלום עולם') || 
                              lines[1].contains('שלום עולם');
      
      expect(rtlSegmentIntact, isTrue);
    });
    
    test('Handles mixed text with multiple RTL segments', () {
      const text = 'Hello שלום world مرحبا test';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(10);
      
      expect(lines.length, greaterThan(1));
      
      for (final line in lines) {
        expect(line.length, lessThanOrEqualTo(10));
      }
    });
    
    test('Handles empty text', () {
      final rope = BidiRope.fromString('');
      
      final lines = rope.breakLinesSimple(10);
      
      expect(lines.length, equals(0));
    });
    
    test('Handles text shorter than max width', () {
      const text = 'Hello';
      final rope = BidiRope.fromString(text);
      
      final lines = rope.breakLinesSimple(10);
      
      expect(lines.length, equals(1));
      expect(lines[0], equals('Hello'));
    });
    
    test('Custom measuring function works', () {
      const text = 'Hello world this is a test';
      final rope = BidiRope.fromString(text);
      
      double customMeasure(String s) {
        double width = 0;
        for (int i = 0; i < s.length; i++) {
          if (s[i].toUpperCase() == s[i] && s[i].toLowerCase() != s[i]) {
            width += 2; 
          } else {
            width += 1; 
          }
        }
        return width;
      }
      
      final lines = rope.breakLines(customMeasure, 12);
      
      expect(lines.length, equals(3));
      expect(lines[0], equals('Hello worl'));
    });
  });
}
