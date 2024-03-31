import 'package:flutter/material.dart';
import 'package:wenznote/service/service_manager.dart';

var _defaultColorMap = <String, Map<String, Color>>{
  "dark": {
    "winNavColor": Colors.grey.shade50,
    "closeImageButtonColor": Colors.grey,
    "shadowBoxColor": Colors.grey.shade800,
    "dialogBackgroundColor": Colors.black.withOpacity(0.1),
    "buttonIconColor": Colors.grey.shade500,
    "textLengthColor": Colors.grey.shade500,
    "borderColor": Colors.grey.shade500,
    "textColor": Colors.white,
    "hintColor": Colors.white.withOpacity(0.6),
  },
  "light": {
    "winNavColor": Colors.grey.shade50,
    "closeImageButtonColor": Colors.grey,
    "shadowBoxColor": Colors.grey.shade500,
    "dialogBackgroundColor": Colors.black.withOpacity(0.2),
    "buttonIconColor": Colors.grey.shade500,
    "textLengthColor": Colors.grey.shade500,
    "borderColor": Colors.grey.shade200,
    "textColor": Colors.black,
    "hintColor": Colors.black.withOpacity(0.6),
  },
};
var _colorMap = _defaultColorMap;

void setColorMap(
    BuildContext context, Map<String, Map<String, Color>> colorMap) {
  _colorMap = colorMap;
}

Color systemColor(BuildContext context, String name) {
  var brightness = ServiceManager.of(context).themeManager.getBrightness();
  if (brightness == Brightness.dark) {
    return _colorMap["dark"]?[name] ?? Colors.black;
  }
  return _colorMap["light"]?[name] ?? Colors.white;
}
