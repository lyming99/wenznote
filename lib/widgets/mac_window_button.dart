import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_button/decorated_button.dart';

Widget buildMacWindowButton(BuildContext context) {
  return Container(
    height: 40,
    child: Row(
      children: [
        if (Platform.isMacOS)
          Container(
            width: 20,
            height: 20,
            child: DecoratedCloseButton(
              onPressed: () {
                windowManager.close();
              },
            ),
          ),
        if (Platform.isMacOS)
          Container(
            width: 20,
            height: 20,
            child: DecoratedMinimizeButton(
              onPressed: () {
                windowManager.minimize();
              },
            ),
          ),
        if (Platform.isMacOS)
          Container(
            width: 20,
            height: 20,
            child: DecoratedMaximizeButton(
              onPressed: () {
                windowManager.maximize();
              },
            ),
          ),
      ],
    ),
  );
}