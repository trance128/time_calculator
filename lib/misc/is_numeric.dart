bool isNumeric(String s) {
  if (s.isEmpty) {
    return true;
  }

  if (s.length == 1) {
    return s.compareTo('0') >= 0 && s.compareTo('9') <= 0;
  }

  return isNumeric(s[0]) && isNumeric(s.substring(1));
}

bool isNumericOrSpecialChars(
  String s, {
  required String chars,
}) {
  if (s.isEmpty) {
    return true;
  }

  if (s.length == 1) {
    return s.compareTo('0') >= 0 && s.compareTo('9') <= 0 || chars.contains(s);
  }

  return isNumericOrSpecialChars(s[0], chars: chars) &&
      isNumericOrSpecialChars(
        s.substring(1),
        chars: chars,
      );
}
