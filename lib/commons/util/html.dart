String htmlSerializeEscape(String text, {bool attributeMode = false}) {
  // TODO(jmesserly): is it faster to build up a list of codepoints?
  // StringBuffer seems cleaner assuming Dart can unbox 1-char strings.
  StringBuffer? result;
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    String? replace;
    switch (ch) {
      case '&':
        replace = '&amp;';
        break;
      case '\u00A0' /*NO-BREAK SPACE*/ :
        replace = '&nbsp;';
        break;
      case '"':
        if (attributeMode) replace = '&quot;';
        break;
      case '<':
        if (!attributeMode) replace = '&lt;';
        break;
      case '>':
        if (!attributeMode) replace = '&gt;';
        break;
    }
    if (replace != null) {
      result ??= StringBuffer(text.substring(0, i));
      result.write(replace);
    } else if (result != null) {
      result.write(ch);
    }
  }

  return result != null ? result.toString() : text;
}