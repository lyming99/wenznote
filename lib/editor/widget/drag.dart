import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

Widget buildDragItem(Widget item) {
  return DragItemWidget(
    dragItemProvider:
        (DragItemRequest request) async {
      // var snap = await snapshot();
      final item = DragItem(
        localData: 'image-item',
        suggestedName: 'item.png',
      );
      // var bytes = await snap.image.toByteData(format: ImageByteFormat.png);
      // var buff = bytes?.buffer.asUint8List();
      // if (buff != null) {
      //   item.add(Formats.png(buff));
      // }
      return item;
    },
    allowedOperations: () {
      return [DropOperation.copy];
    },
    child: DraggableWidget(
      child: item,
    ),
  );
}
