import '../../rope.dart';
import 'bidirectional.dart';

/// This class extends the functionality of the original Rope class
/// to properly handle bidirectional text (mixed LTR and RTL content).
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

  /// Returns a new bidirectional rope containing the characters from [start] to [end].
  BidiRope substring(int start, [int? end]) {
    final actualEnd = end ?? length;

    final subString = _rope.substring(start, actualEnd);
    return BidiRope.fromString(subString);
  }

  BidiRope insert(int index, String text) {
    final newRope = _rope.insert(index, text);
    final newText = newRope.toString();
    final containsRtl = BidirectionalText.containsRtl(newText);

    return BidiRope._(newRope, containsRtl);
  }

  BidiRope delete(int start, int end) {
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
    final (leftRope, rightRope) = _rope.split(index);

    final leftText = leftRope.toString();
    final rightText = rightRope.toString();

    final leftContainsRtl = BidirectionalText.containsRtl(leftText);
    final rightContainsRtl = BidirectionalText.containsRtl(rightText);

    return (
      BidiRope._(leftRope, leftContainsRtl),
      BidiRope._(rightRope, rightContainsRtl)
    );
  }

  String charAt(int index) {
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
