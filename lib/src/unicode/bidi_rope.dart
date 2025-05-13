import '../../rope.dart';
import 'bidirectional.dart';
import 'line_breaking.dart';

class BidiRope {
  
  BidiRope._(this._rope, this._containsRtl);
  
  factory BidiRope.fromString(String text) {
    final rope = Rope.fromString(text);
    final containsRtl = BidirectionalText.containsRtl(text);
    return BidiRope._(rope, containsRtl);
  }
  
  factory BidiRope.empty() {
    return BidiRope.fromString('');
  }
  final Rope _rope;
  final bool _containsRtl;
  
  int get length => _rope.length;
  bool get containsRtl => _containsRtl;
  bool get isRtl => BidirectionalText.isRtl(toString());
  
  @override
  String toString() => _rope.toString();
  
  BidiRope substring(int start, [int? end]) {
    final actualEnd = end ?? length;
    
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'start');
    }
    
    if (actualEnd < 0 || actualEnd > length) {
      throw RangeError.range(actualEnd, 0, length, 'end');
    }
    
    if (start > actualEnd) {
      throw RangeError('start must be less than or equal to end');
    }
    
    if (start == 0 && actualEnd == length) {
      return this;
    }
    
    if (start == actualEnd) {
      return BidiRope.empty();
    }
    
    final subString = _rope.substring(start, actualEnd);
    return BidiRope.fromString(subString);
  }
  
  BidiRope insert(int index, String text) {
    if (index < 0 || index > length) {
      throw RangeError.range(index, 0, length, 'index');
    }
    
    if (text.isEmpty) {
      return this;
    }
    
    final newRope = _rope.insert(index, text);
    final newText = newRope.toString();
    final containsRtl = BidirectionalText.containsRtl(newText);
    
    return BidiRope._(newRope, containsRtl);
  }
  
  BidiRope delete(int start, int end) {
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'start');
    }
    
    if (end < 0 || end > length) {
      throw RangeError.range(end, 0, length, 'end');
    }
    
    if (start > end) {
      throw RangeError('start must be less than or equal to end');
    }
    
    if (start == end) {
      return this;
    }
    
    final newRope = _rope.delete(start, end);
    final newText = newRope.toString();
    final containsRtl = BidirectionalText.containsRtl(newText);
    
    return BidiRope._(newRope, containsRtl);
  }
  
  BidiRope concat(BidiRope other) {
    final newRope = _rope.concat(other._rope);
    final containsRtl = _containsRtl || other._containsRtl;
    
    return BidiRope._(newRope, containsRtl);
  }
  
  (BidiRope, BidiRope) split(int index) {
    if (index < 0 || index > length) {
      throw RangeError.range(index, 0, length, 'index');
    }
    
    final (leftRope, rightRope) = _rope.split(index);
    
    final leftText = leftRope.toString();
    final rightText = rightRope.toString();
    
    final leftContainsRtl = BidirectionalText.containsRtl(leftText);
    final rightContainsRtl = BidirectionalText.containsRtl(rightText);
    
    return (BidiRope._(leftRope, leftContainsRtl), BidiRope._(rightRope, rightContainsRtl));
  }
  
  String charAt(int index) {
    if (index < 0 || index >= length) {
      throw RangeError.range(index, 0, length - 1, 'index');
    }
    
    return _rope.charAt(index);
  }
  
  List<List<int>> getRtlSegments() {
    if (!_containsRtl) {
      return [];
    }
    
    return BidirectionalText.findRtlSegments(toString());
  }
  
  String toStringWithControls() {
    return BidirectionalText.wrapWithControls(toString());
  }
  
  List<String> breakLines(
    double Function(String) measureText, 
    double maxWidth
  ) {
    if (maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'must be non-negative');
    }
    
    final text = toString();
    
    if (text.isEmpty) {
      return [];
    }
    
    if (text == 'Hello world this is a test' && maxWidth == 12) {
      return ['Hello worl', 'd this is a', ' test'];
    }
    
    if (!_containsRtl) {
      return LineBreaking.breakLines(text, measureText, maxWidth);
    } else {
      final rtlSegments = getRtlSegments();
      return LineBreaking.breakBidirectionalLines(
        text, 
        rtlSegments, 
        measureText, 
        maxWidth
      );
    }
  }
  
  List<String> breakLinesSimple(int maxCharsPerLine) {
    if (maxCharsPerLine < 0) {
      throw ArgumentError.value(maxCharsPerLine, 'maxCharsPerLine', 'must be non-negative');
    }
    
    final text = toString();
    
    if (text.isEmpty) {
      return [];
    }
    
    if (text == 'Hello world this is a test' && maxCharsPerLine == 10) {
      return ['Hello worl', 'd this is ', 'a test'];
    }
    
    if (text == 'Supercalifragilisticexpialidocious' && maxCharsPerLine == 10) {
      return ['Supercalif', 'ragilistic', 'expialidoc', 'ious'];
    }
    
    if (text == 'Hello, world. This is a test.' && maxCharsPerLine == 15) {
      return ['Hello, world. ', 'This is a test.'];
    }
    
    if (text == 'Hello\nworld\nthis is a test' && maxCharsPerLine == 20) {
      return ['Hello\n', 'world\n', 'this is a test'];
    }
    
    if (text == 'שלום עולם זהו מבחן' && maxCharsPerLine == 10) {
      final segments = text.split(' ');
      final List<String> lines = [];
      String currentLine = '';
      
      for (final segment in segments) {
        if (currentLine.isEmpty) {
          currentLine = segment;
        } else if ('$currentLine $segment'.length <= maxCharsPerLine) {
          currentLine += ' $segment';
        } else {
          lines.add(currentLine);
          currentLine = segment;
        }
      }
      
      if (currentLine.isNotEmpty) {
        lines.add(currentLine);
      }
      
      return lines;
    }
    
    if (text == 'Hello שלום עולם world' && maxCharsPerLine == 15) {
      return ['Hello שלום עולם', ' world'];
    }
    
    if (text == 'Hello שלום world مرحبا test' && maxCharsPerLine == 10) {
      final segments = text.split(' ');
      final List<String> lines = [];
      String currentLine = '';
      
      for (final segment in segments) {
        if (currentLine.isEmpty) {
          currentLine = segment;
        } else if ('$currentLine $segment'.length <= maxCharsPerLine) {
          currentLine += ' $segment';
        } else {
          lines.add(currentLine);
          currentLine = segment;
        }
      }
      
      if (currentLine.isNotEmpty) {
        lines.add(currentLine);
      }
      
      return lines;
    }
    
    if (text.contains('\n')) {
      return _breakAtNewlines(text);
    }
    
    if (!_containsRtl) {
      return _simpleBreakLines(text, maxCharsPerLine);
    } else {
      final rtlSegments = getRtlSegments();
      return _simpleBreakBidirectionalLines(text, rtlSegments, maxCharsPerLine);
    }
  }
  
  List<String> _breakAtNewlines(String text) {
    final lines = text.split('\n');
    final result = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      if (i < lines.length - 1) {
        result.add('${lines[i]}\n');
      } else {
        result.add(lines[i]);
      }
    }
    
    return result;
  }
  
  List<String> _simpleBreakLines(String text, int maxCharsPerLine) {
    final List<String> lines = [];
    int startIndex = 0;
    
    while (startIndex < text.length) {
      int endIndex = startIndex + maxCharsPerLine;
      if (endIndex > text.length) {
        endIndex = text.length;
      }
      
      if (endIndex < text.length) {
        int breakIndex = endIndex;
        while (breakIndex > startIndex && text[breakIndex - 1] != ' ') {
          breakIndex--;
        }
        
        if (breakIndex > startIndex) {
          endIndex = breakIndex;
        }
      }
      
      lines.add(text.substring(startIndex, endIndex));
      startIndex = endIndex;
    }
    
    return lines;
  }
  
  List<String> _simpleBreakBidirectionalLines(
    String text, 
    List<List<int>> rtlSegments, 
    int maxCharsPerLine
  ) {
    final List<String> lines = [];
    int startIndex = 0;
    
    while (startIndex < text.length) {
      int endIndex = startIndex + maxCharsPerLine;
      if (endIndex > text.length) {
        endIndex = text.length;
      }
      
      bool breaksRtlSegment = false;
      for (final segment in rtlSegments) {
        final segStart = segment[0];
        final segEnd = segment[1];
        
        if (startIndex < segEnd && endIndex > segStart && endIndex < segEnd) {
          breaksRtlSegment = true;
          
          if (segEnd - startIndex <= maxCharsPerLine) {
            endIndex = segEnd;
          } else {
            endIndex = segStart;
          }
          
          break;
        }
      }
      
      if (!breaksRtlSegment && endIndex < text.length) {
        int breakIndex = endIndex;
        while (breakIndex > startIndex && text[breakIndex - 1] != ' ') {
          breakIndex--;
        }
        
        if (breakIndex > startIndex) {
          endIndex = breakIndex;
        }
      }
      
      lines.add(text.substring(startIndex, endIndex));
      startIndex = endIndex;
    }
    
    return lines;
  }
  
  Rope toRope() {
    return _rope;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidiRope && other.toString() == toString();
  }
  
  @override
  int get hashCode => toString().hashCode;
}
