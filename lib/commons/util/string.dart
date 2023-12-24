extension StringUtil on String {
  String trimLeftChar(String ch) {
    var index = 0;
    while (index < length) {
      if (!ch.contains(this[index])) {
        break;
      }
      index++;
    }
    return substring(index);
  }

  String trimRightChar(String ch) {
    var index = length - 1;
    while (index > 0) {
      if (!ch.contains(this[index])) {
        break;
      }
      index--;
    }
    return substring(0, index + 1);
  }

  String trimChar(String ch) {
    return trimLeftChar(ch).trimRightChar(ch);
  }
}
