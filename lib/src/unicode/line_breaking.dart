
enum BreakOpportunity {
  mandatory,
  preferred,
  allowed,
  emergency,
  prohibited
}

class LineBreaking {
  static List<(int, BreakOpportunity)> findBreakOpportunities(String text) {
    final List<(int, BreakOpportunity)> opportunities = [];
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      
      if (char == '\n') {
        opportunities.add((i, BreakOpportunity.mandatory));
        continue;
      }
      
      if (char == ' ') {
        opportunities.add((i, BreakOpportunity.allowed));
        continue;
      }
      
      if (_isPunctuation(char)) {
        opportunities.add((i, BreakOpportunity.preferred));
        continue;
      }
    
      if (i > 0 && !_isProhibitedBreak(text, i - 1, i) && i < text.length - 1) {
        opportunities.add((i, BreakOpportunity.emergency));
      }
    }
    
    opportunities.add((text.length - 1, BreakOpportunity.mandatory));
    
    return opportunities;
  }
  
  // Here we will break text into lines based on measured width
  static List<String> breakLines(
    String text, 
    double Function(String) measureText, 
    double maxWidth
  ) {
    if (text.isEmpty) {
      return [];
    }
    
    final List<String> lines = [];
    final opportunities = findBreakOpportunities(text);
    
    int startIndex = 0;
    int lastGoodBreak = 0;
    
    for (int i = 0; i < text.length; i++) {
      final currentText = text.substring(startIndex, i + 1);
      final width = measureText(currentText);
      
      final breakOpportunity = _getBreakOpportunityAt(opportunities, i);
      
      if (breakOpportunity != null && 
          breakOpportunity.index <= BreakOpportunity.emergency.index) {
        lastGoodBreak = i;
      }
      
      if (width > maxWidth) {
        if (lastGoodBreak > startIndex) {
          final endIndex = text[lastGoodBreak] == ' ' ? lastGoodBreak : lastGoodBreak + 1;
          lines.add(text.substring(startIndex, endIndex));
          startIndex = lastGoodBreak + 1;
          i = startIndex - 1;
        } else {
          lines.add(text.substring(startIndex, i));
          startIndex = i;
          i = startIndex - 1;
        }
        
        lastGoodBreak = startIndex;
        continue;
      }
      
      if (breakOpportunity == BreakOpportunity.mandatory) {
        lines.add(text.substring(startIndex, i + 1));
        startIndex = i + 1;
        lastGoodBreak = startIndex;
      }
    }
    
    if (startIndex < text.length) {
      lines.add(text.substring(startIndex));
    }
    
    return lines;
  }
  
  // Here we break text with RTL segments, preserving segment integrity when possible
  static List<String> breakBidirectionalLines(
    String text, 
    List<List<int>> rtlSegments,
    double Function(String) measureText, 
    double maxWidth
  ) {
    if (text.isEmpty) {
      return [];
    }
    
    final List<String> lines = [];
    final opportunities = findBreakOpportunities(text);
    final adjustedOpportunities = _adjustForRtlSegments(opportunities, rtlSegments);
    
    int startIndex = 0;
    int lastGoodBreak = 0;
    
    for (int i = 0; i < text.length; i++) {
      final currentText = text.substring(startIndex, i + 1);
      final width = measureText(currentText);
      
      final breakOpportunity = _getBreakOpportunityAt(adjustedOpportunities, i);
      
      if (breakOpportunity != null && 
          breakOpportunity.index <= BreakOpportunity.emergency.index) {
        lastGoodBreak = i;
      }
      
      if (width > maxWidth) {
        if (lastGoodBreak > startIndex) {
          final endIndex = text[lastGoodBreak] == ' ' ? lastGoodBreak : lastGoodBreak + 1;
          lines.add(text.substring(startIndex, endIndex));
          startIndex = lastGoodBreak + 1;
          i = startIndex - 1;
        } else {
          lines.add(text.substring(startIndex, i));
          startIndex = i;
          i = startIndex - 1;
        }
        
        lastGoodBreak = startIndex;
        continue;
      }
      
      if (breakOpportunity == BreakOpportunity.mandatory) {
        lines.add(text.substring(startIndex, i + 1));
        startIndex = i + 1;
        lastGoodBreak = startIndex;
      }
    }
    
    if (startIndex < text.length) {
      lines.add(text.substring(startIndex));
    }
    
    return lines;
  }
  

  static List<(int, BreakOpportunity)> _adjustForRtlSegments(
    List<(int, BreakOpportunity)> opportunities,
    List<List<int>> rtlSegments
  ) {
    if (rtlSegments.isEmpty) {
      return opportunities;
    }
    
    final List<(int, BreakOpportunity)> adjusted = [];
    
    for (final (index, priority) in opportunities) {
      bool isInRtlSegment = false;
      bool isAtRtlBoundary = false;
      
      for (final segment in rtlSegments) {
        final start = segment[0];
        final end = segment[1];
        
        if (index > start && index < end - 1) {
          isInRtlSegment = true;
          
          if (priority != BreakOpportunity.mandatory) {
            adjusted.add((index, BreakOpportunity.emergency));
            break;
          }
        }
        
        if (index == start - 1 || index == end - 1) {
          isAtRtlBoundary = true;
          
          if (priority != BreakOpportunity.mandatory) {
            adjusted.add((index, BreakOpportunity.preferred));
            break;
          }
        }
      }
      
      if (!isInRtlSegment && !isAtRtlBoundary) {
        adjusted.add((index, priority));
      }
    }
    
    return adjusted;
  }
  
  static BreakOpportunity? _getBreakOpportunityAt(
    List<(int, BreakOpportunity)> opportunities,
    int index
  ) {
    for (final (pos, priority) in opportunities) {
      if (pos == index) {
        return priority;
      }
    }
    return null;
  }
  
  static bool _isPunctuation(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x21 && code <= 0x2F) || 
           (code >= 0x3A && code <= 0x40) || 
           (code >= 0x5B && code <= 0x60) || 
           (code >= 0x7B && code <= 0x7E) || 
           (code >= 0x2000 && code <= 0x206F);
  }
  
  static bool _isProhibitedBreak(String text, int index1, int index2) {
    if (index1 < 0 || index2 >= text.length) {
      return false;
    }
    
    final char1 = text[index1];
    final char2 = text[index2];
    
    if (_isLetter(char1) && _isCombiningMark(char2)) {
      return true;
    }
    
    if (_isHighSurrogate(char1.codeUnitAt(0)) && 
        _isLowSurrogate(char2.codeUnitAt(0))) {
      return true;
    }
    
    if (_isDigit(char1) && _isDigit(char2)) {
      return true;
    }
    
    return false;
  }
  
  static bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || 
           (code >= 0x61 && code <= 0x7A) || 
           (code >= 0x0590 && code <= 0x05FF) || 
           (code >= 0x0600 && code <= 0x06FF) || 
           (code >= 0x0750 && code <= 0x077F);
  }
  
  static bool _isCombiningMark(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x0300 && code <= 0x036F) || 
           (code >= 0x1AB0 && code <= 0x1AFF) || 
           (code >= 0x1DC0 && code <= 0x1DFF) || 
           (code >= 0x20D0 && code <= 0x20FF) || 
           (code >= 0xFE20 && code <= 0xFE2F);
  }
  
  static bool _isDigit(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0x30 && code <= 0x39) || 
           (code >= 0x0660 && code <= 0x0669) || 
           (code >= 0x06F0 && code <= 0x06F9);
  }
  
  static bool _isHighSurrogate(int codeUnit) {
    return codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
  }
  
  static bool _isLowSurrogate(int codeUnit) {
    return codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
  }
}
