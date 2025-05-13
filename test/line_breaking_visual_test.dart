import 'dart:io';
import 'package:rope/bidi_rope.dart';

/// A more interactive test for line breaking.
/// 
/// This test allows you to enter text and see how it's broken into lines
/// with different maximum widths.
void main() {
  print('=== INTERACTIVE LINE BREAKING TEST ===');
  print('Enter text to test line breaking (or "exit" to quit):');
  
  while (true) {
    stdout.write('> ');
    final input = stdin.readLineSync();
    
    if (input == null || input.toLowerCase() == 'exit') {
      break;
    }
    
    if (input.isEmpty) {
      print('Please enter some text.');
      continue;
    }
    
    final rope = BidiRope.fromString(input);
    
    final rtlSegments = rope.getRtlSegments();
    if (rtlSegments.isNotEmpty) {
      print('RTL segments detected:');
      for (final segment in rtlSegments) {
        final start = segment[0];
        final end = segment[1];
        print('  $start-$end: "${input.substring(start, end)}"');
      }
    } else {
      print('No RTL segments detected.');
    }
    
    for (final maxWidth in [10, 20, 30, 40]) {
      print('\nBreaking with max width: $maxWidth');
      final lines = rope.breakLinesSimple(maxWidth);
      
      print('Resulting ${lines.length} lines:');
      for (int i = 0; i < lines.length; i++) {
        print('  ${i + 1}: "${lines[i]}" (length: ${lines[i].length})');
      }
      
      print('\nVisual representation:');
      print('----------------------------------------');
      for (final line in lines) {
        print('| $line');
      }
      print('----------------------------------------');
    }
    
    print('\nEnter another text to test (or "exit" to quit):');
  }
  
  print('Goodbye!');
}
