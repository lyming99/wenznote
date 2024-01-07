import 'package:flutter/material.dart';
import 'package:note/app/app.dart';

import '../../commons/service/device_utils.dart';

Future<void> mobileMain(
    {bool test = false, List<String> args = const []}) async {
  await readDeviceInfo();
  runApp(AppWidget(controller: AppController()));
}
