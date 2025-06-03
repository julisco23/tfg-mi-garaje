import 'dart:math';

class FamilyCodeGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String generate() {
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => _chars.codeUnitAt(Random().nextInt(_chars.length)),
      ),
    );
  }
}
