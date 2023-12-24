import 'dart:io';

import 'package:flutter/material.dart';
import 'package:note/app/windows/windows_main.dart';

const bool test = false;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  print('exe:${ Platform.resolvedExecutable}');
  if (isDesktop) {
    await windowsMain(test: test,args: args);
  } else {
    await windowsMain(test: test,args: args);
  }
}
