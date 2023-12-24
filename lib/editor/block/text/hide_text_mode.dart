
enum HideTextMode {
  underline,
  color,
  background,
  formula;

  static HideTextMode? forName(String? name) {
    if (name == "underline") {
      return HideTextMode.underline;
    }
    if (name == "color") {
      return HideTextMode.color;
    }
    if (name == "background") {
      return HideTextMode.background;
    }
    if (name == "formula") {
      return HideTextMode.formula;
    }
    return null;
  }

  String getDisplayName() {
    switch (this) {
      case underline:
        return "下划线";
      case color:
        return "字体色";
      case background:
        return "背景色";
      case formula:
        return "公式";
    }
  }
}