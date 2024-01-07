import 'package:flutter/material.dart';
import 'package:note/app/mobile/mobile_main.dart';
import 'package:note/app/windows/windows_main.dart';

const bool test = false;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktop) {
    // await mobileMain(test: test, args: args);
    await windowsMain(test: test, args: args);
  } else {
    await mobileMain(test: test, args: args);
  }
}
