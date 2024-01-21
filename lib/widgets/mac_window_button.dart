import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_button/decorated_button.dart';

Widget buildMacWindowButton(BuildContext context) {
  return SizedBox(
    height: 40,
    child: Row(
      children: [
        if (Platform.isMacOS)
          SizedBox(
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
              onPressed: () async{
                var isMax = await windowManager.isMaximized();
                if(isMax) {
                  windowManager.unmaximize();
                }else{
                  windowManager.maximize();
                }
              },
            ),
          ),
      ],
    ),
  );
}