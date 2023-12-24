import 'package:flutter/material.dart';

class WindowUserButton extends StatefulWidget {
  final Brightness? brightness;
  final Widget? icon;
  final VoidCallback? onPressed;

  _ButtonBgColorScheme _lightButtonBgColorScheme = _ButtonBgColorScheme(
    normal: Colors.transparent,
    hovered: Colors.black.withOpacity(0.0373),
    pressed: Colors.black.withOpacity(0.0241),
  );
  _ButtonIconColorScheme _lightButtonIconColorScheme = _ButtonIconColorScheme(
    normal: Colors.black.withOpacity(0.8956),
    hovered: Colors.black.withOpacity(0.8956),
    pressed: Colors.black.withOpacity(0.6063),
    disabled: Colors.black.withOpacity(0.3614),
  );
  _ButtonBgColorScheme _darkButtonBgColorScheme = _ButtonBgColorScheme(
    normal: Colors.transparent,
    hovered: Colors.white.withOpacity(0.0605),
    pressed: Colors.white.withOpacity(0.0419),
  );
  _ButtonIconColorScheme _darkButtonIconColorScheme = _ButtonIconColorScheme(
    normal: Colors.white,
    hovered: Colors.white,
    pressed: Colors.white.withOpacity(0.786),
    disabled: Colors.black.withOpacity(0.3628),
  );

  WindowUserButton({
    Key? key,
    this.brightness,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  WindowUserButton.minimize({
    Key? key,
    this.brightness,
    this.icon,
    this.onPressed,
  })  :
        super(key: key);

  _ButtonBgColorScheme get buttonBgColorScheme => brightness != Brightness.dark
      ? _lightButtonBgColorScheme
      : _darkButtonBgColorScheme;

  _ButtonIconColorScheme get buttonIconColorScheme =>
      brightness != Brightness.dark
          ? _lightButtonIconColorScheme
          : _darkButtonIconColorScheme;

  @override
  State<WindowUserButton> createState() => _WindowUserButtonState();
}

class _WindowUserButtonState extends State<WindowUserButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  void _onEntered({required bool hovered}) {
    setState(() => _isHovering = hovered);
  }

  void _onActive({required bool pressed}) {
    setState(() => _isPressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.buttonBgColorScheme.normal;
    Color iconColor = widget.buttonIconColorScheme.normal;

    if (_isHovering) {
      bgColor = widget.buttonBgColorScheme.hovered;
      iconColor = widget.buttonIconColorScheme.hovered;
    }
    if (_isPressed) {
      bgColor = widget.buttonBgColorScheme.pressed;
      iconColor = widget.buttonIconColorScheme.pressed;
    }

    return MouseRegion(
      onExit: (value) => _onEntered(hovered: false),
      onHover: (value) => _onEntered(hovered: true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _onActive(pressed: true),
        onTapCancel: () => _onActive(pressed: false),
        onTapUp: (_) => _onActive(pressed: false),
        onTap: widget.onPressed,
        child: Container(
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          decoration: BoxDecoration(
            color: bgColor,
          ),
          alignment: Alignment.center,
          child: Center(
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}

class _ButtonBgColorScheme {
  final Color normal;
  final Color hovered;
  final Color pressed;

  _ButtonBgColorScheme({
    required this.normal,
    required this.hovered,
    required this.pressed,
  });
}

class _ButtonIconColorScheme {
  final Color normal;
  final Color hovered;
  final Color pressed;
  final Color disabled;

  _ButtonIconColorScheme({
    required this.normal,
    required this.hovered,
    required this.pressed,
    required this.disabled,
  });
}