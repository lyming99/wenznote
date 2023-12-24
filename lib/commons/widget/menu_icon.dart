import 'package:fluent_ui/fluent_ui.dart';

class MenuIcon extends StatelessWidget {
  Color? color;
  double? size;

  MenuIcon({
    Key? key,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);

    final double iconSize = size ?? iconTheme.size ?? 16;
    final Color? iconColor = color ?? iconTheme.color;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Column(
        children: [
          Flexible(child: Container()),
          Container(
            color: iconColor ?? Colors.black,
            height: 1.1 / 16 * iconSize,
            margin: EdgeInsets.symmetric(horizontal: 1),
          ),
          Flexible(child: Container()),
          Container(
            color: iconColor ?? Colors.black,
            height: 1.1 / 16 * iconSize,
            margin: EdgeInsets.symmetric(horizontal: 1),
          ),
          Flexible(child: Container()),
          Container(
            color: iconColor ?? Colors.black,
            height: 1.1 / 16 * iconSize,
            margin: EdgeInsets.symmetric(horizontal: 1),
          ),
          Flexible(child: Container()),
        ],
      ),
    );
  }
}
