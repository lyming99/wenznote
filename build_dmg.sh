#!/bin/sh
test -f Application-Installer.dmg && rm Application-Installer.dmg
create-dmg \
  --volname "Application Installer" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --app-drop-link 600 185 \
  "Application-Installer.dmg" \
  "build/macos/Build/Products/Release/温知笔记.app"

#"Application-Installer.dmg"是.dmg文件名称。
#"source_folder/"是"flutter build macos --release"结果路径，如：/工程目录/build/macos/Build/Products/Release/xxx.app