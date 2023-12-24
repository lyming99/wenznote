import 'dart:io';

import 'package:note/service/task/task.dart';

void main() async {
  for (var i = 0; i < 10000; i++) {
    TaskService.instance.executeTask(
      task: () async {
        print('task$i');
      },
    );
  }
}
