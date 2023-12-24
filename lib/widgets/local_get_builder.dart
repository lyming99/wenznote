import 'package:get/get.dart';

GetBuilder<T> createLocalGetBuilder<T extends GetxController>({
  required T controller,
  required GetControllerBuilder<T> builder,
}) {
  return GetBuilder(
    global: false,
    init: controller,
    autoRemove: false,
    dispose: (c) {
      controller.onClose();
    },
    builder: builder,
  );
}
