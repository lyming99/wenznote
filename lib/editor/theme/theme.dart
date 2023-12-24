import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class EditTheme {
  final bool isDark;
  final Color bgColor;
  final Color bgColor2;
  final Color bgColor3;
  final Color codeBgColor;
  final Color fontColor;
  final Color fontColor2;
  final Color linkColor;
  final Color cursorColor;
  final Color navIndicateColor;
  final Color navUnSelectColor;
  final Color treeItemSelectColor;
  final Color treeItemHoverColor;
  final Color scrollBarDefaultColor;
  final Color scrollBarHoverColor;
  final Color scrollBarHoverBgColor;
  final Color checkedColor;
  final Color uncheckedColor;
  final Color quoteBgColor;
  final Color quoteBarColor;
  final Color dropColor;
  final Color borderColor;
  final Color lineColor;
  final Color windowTitleColor;
  final Color mobileBgColor;
  final Color mobileContentBgColor;
  final Color mobileNavBgColor;
  final Color floatingButtonColor;
  final Color mobileNavActiveColor;

  static SystemUiOverlayStyle overlayStyle(
    context, {
    bool reverse = false,
  }) {
    var isLight = Theme.of(context).brightness == Brightness.dark;
    if (reverse) {
      isLight = !isLight;
    }
    return isLight ? lightOverlayStyle(context) : darkOverlayStyle(context);
  }

  static SystemUiOverlayStyle darkOverlayStyle(context) {
    return SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: EditTheme.of(context).mobileNavBgColor,
      systemNavigationBarDividerColor: EditTheme.of(context).mobileNavBgColor,
    );
  }

  static SystemUiOverlayStyle lightOverlayStyle(context) {
    return SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: EditTheme.of(context).mobileNavBgColor,
      systemNavigationBarDividerColor: EditTheme.of(context).mobileNavBgColor,
    );
  }

  double get fontSize {
    return 16;
  }

  const EditTheme.create({
    required this.isDark,
    required this.bgColor,
    required this.bgColor2,
    required this.bgColor3,
    required this.codeBgColor,
    required this.fontColor,
    required this.fontColor2,
    required this.linkColor,
    required this.cursorColor,
    required this.navIndicateColor,
    required this.navUnSelectColor,
    required this.treeItemSelectColor,
    required this.treeItemHoverColor,
    required this.scrollBarDefaultColor,
    required this.scrollBarHoverColor,
    required this.scrollBarHoverBgColor,
    required this.checkedColor,
    required this.uncheckedColor,
    required this.quoteBgColor,
    required this.quoteBarColor,
    required this.dropColor,
    required this.borderColor,
    required this.lineColor,
    required this.windowTitleColor,
    required this.mobileBgColor,
    required this.mobileContentBgColor,
    required this.mobileNavBgColor,
    required this.floatingButtonColor,
    required this.mobileNavActiveColor,
  });

  static EditTheme dark = const EditTheme.create(
    isDark: true,
    bgColor: Color(0xff484848),
    bgColor2: Color(0xff383838),
    bgColor3: Color(0xff2c2c2c),
    fontColor: Colors.white,
    fontColor2: Color(0xffd2d2d2),
    linkColor: Colors.blue,
    cursorColor: Color(0xfffa5902),
    navIndicateColor: Color(0xff002085),
    navUnSelectColor: Color(0xffa6a6a6),
    codeBgColor: Color(0xff212121),
    treeItemSelectColor: Color(0xff194176),
    treeItemHoverColor: Color(0xff2D2D2D),
    scrollBarDefaultColor: Color(0x33666666),
    scrollBarHoverColor: Color(0x33AAAAAA),
    scrollBarHoverBgColor: Color(0x33666666),
    checkedColor: Color(0xff038d44),
    uncheckedColor: Color(0xffeeeeee),
    quoteBgColor: Color(0xff333333),
    quoteBarColor: Color(0xff444444),
    dropColor: Color(0x22000000),
    borderColor: Color(0x22ffffff),
    lineColor: Color(0x22ffffff),
    windowTitleColor: Color(0xFFB7B7B7),
    mobileBgColor: Color(0xff111111),
    mobileContentBgColor: Color(0xff1f1f1f),
    mobileNavBgColor: Color(0xff1f1f1f),
    floatingButtonColor: Color(0xfffa5902),
    mobileNavActiveColor: Colors.white,
  );

  static EditTheme light = EditTheme.create(
    isDark: false,
    bgColor: const Color(0xffffffff),
    bgColor2: const Color(0xffffffff),
    bgColor3: const Color(0xfffcfcfc),
    fontColor: const Color(0xff000000),
    fontColor2: const Color(0xffadadad),
    linkColor: Colors.blue,
    codeBgColor: const Color(0xffefefef),
    cursorColor: const Color(0xfffa5902),
    navIndicateColor: const Color(0xff002085),
    navUnSelectColor: const Color(0xffa6a6a6),
    treeItemSelectColor: const Color(0xffD8E8FA),
    treeItemHoverColor: const Color(0xffF2F2F2),
    scrollBarDefaultColor: const Color(0x66999999),
    scrollBarHoverColor: const Color(0x99999999),
    scrollBarHoverBgColor: const Color(0x33999999),
    checkedColor: const Color(0xff038d44),
    uncheckedColor: const Color(0xff666666),
    quoteBgColor: const Color(0xffeeeeee),
    quoteBarColor: const Color(0xffdddddd),
    dropColor: const Color(0x22000000),
    borderColor: const Color(0x22000000),
    lineColor: const Color(0x22000000),
    windowTitleColor: const Color(0xFF707070),
    mobileBgColor: fluent.Colors.grey[20],
    mobileContentBgColor: fluent.Colors.white,
    mobileNavBgColor: const Color(0xFFFFFFFF),
    floatingButtonColor: const Color(0xfff52e02),
    mobileNavActiveColor: Colors.black87,
  );

  static EditTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }

  static Color? buildColor(
    BuildContext context, {
    Color? darkColor,
    Color? lightColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }
}
