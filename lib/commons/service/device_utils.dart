import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

WindowsDeviceInfo? windowsDeviceInfo;
AndroidDeviceInfo? androidDeviceInfo;
LinuxDeviceInfo? linuxDeviceInfo;
MacOsDeviceInfo? macOsDeviceInfo;
IosDeviceInfo? iosDeviceInfo;

Future<void> readDeviceInfo() async {
  if (Platform.isWindows) {
    windowsDeviceInfo = await DeviceInfoPlugin().windowsInfo;
  } else if (Platform.isAndroid) {
    androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
  } else if (Platform.isIOS) {
    iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
  } else if (Platform.isLinux) {
    linuxDeviceInfo = await DeviceInfoPlugin().linuxInfo;
  } else if (Platform.isMacOS) {
    macOsDeviceInfo = await DeviceInfoPlugin().macOsInfo;
  }
}

bool isWin11() {
  return (windowsDeviceInfo?.buildNumber ?? 0) >= 22000;
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}
