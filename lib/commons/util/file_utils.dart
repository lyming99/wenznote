import 'dart:io';

import 'package:path/path.dart' as path;

void copyDirectorySync(Directory source, Directory destination) {
  /// create destination folder if not exist
  if (!destination.existsSync()) {
    destination.createSync(recursive: true);
  }

  /// get all files from source (recursive: false is important here)
  source.listSync(recursive: false).forEach((entity) {
    final newPath =
        destination.path + Platform.pathSeparator + path.basename(entity.path);
    if (entity is File) {
      entity.copySync(newPath);
    } else if (entity is Directory) {
      copyDirectorySync(entity, Directory(newPath));
    }
  });
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  /// create destination folder if not exist
  if (!destination.existsSync()) {
    await destination.create(recursive: true);
  }

  /// get all files from source (recursive: false is important here)
  var list = source.listSync(recursive: false);
  for (var entity in list) {
    final newPath =
        destination.path + Platform.pathSeparator + path.basename(entity.path);
    if (entity is File) {
      await entity.copy(newPath);
    } else if (entity is Directory) {
      await copyDirectory(entity, Directory(newPath));
    }
  }
}

String getFileSuffix(String file) {
  var index = file.lastIndexOf(".");
  if (index != -1) {
    return file.substring(index);
  }
  return "";
}

String getFileName(String file) {
  file = file.replaceAll("\\\\", "/");
  var index = file.lastIndexOf("/");
  if (index != -1) {
    return file.substring(index + 1);
  }
  return file;
}

String getFileType(String file) {
  var lower = file.toLowerCase();
  var suffix = getFileSuffix(lower);
  if (suffix.endsWith("png") ||
      suffix.endsWith("jpg") ||
      suffix.endsWith("jpeg") ||
      suffix.endsWith("gif") ||
      suffix.endsWith("webp")) {
    return "image";
  }
  return suffix;
}
