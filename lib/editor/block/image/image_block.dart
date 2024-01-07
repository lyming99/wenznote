import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:note/editor/widget/modal_widget.dart';
import 'package:octo_image/octo_image.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../../edit_controller.dart';
import '../block.dart';
import '../element/element.dart';
import '../text/text.dart';
import 'image_element.dart';
import 'image_viewer.dart';
import 'multi_source_file_image.dart';

class ImageBlock extends WenBlock {
  bool delete = false;
  double imageWidth = 0;
  double imageHeight = 0;
  double padding = 1;
  @override
  WenImageElement element;
  bool showPopup = false;

  ImageBlock({
    required context,
    required this.element,
    required super.editController,
  }) : super(context: context) {
    readImageId();
  }

  void readImageId() async {
    if (element.file == "" || !File(element.file).existsSync()) {
      element.file =
          (await editController.fileManager.getImageFile(element.id)) ?? "";
      relayoutFlag = true;
      editController.updateWidgetState();
    }
  }

  double calcIndentWidth() {
    if (calcAlignment() == Alignment.topLeft) {
      var width = indentWidth * (element.indent ?? 0);
      if (width > max(0, this.width - imageWidth - padding * 2)) {
        return max(0, this.width - imageWidth - padding * 2);
      }
      return width;
    }
    return 0;
  }

  bool get isSelected =>
      selected && selectedStart?.offset == 0 && selectedEnd?.offset == 1;

  @override
  Widget buildWidget(BuildContext context) {
    this.context = context;
    if (delete) {
      return Container(
        padding: EdgeInsets.all(padding),
      );
    }
    var alignment = calcAlignment();
    var offsetX = calcIndentWidth();
    return Container(
      padding: offsetX > 0 ? EdgeInsets.only(left: offsetX) : null,
      height: height,
      child: Stack(
        children: [
          Align(
            alignment: alignment,
            child: DragItemWidget(
              dragItemProvider: (session) async {
                if (editController.isMobile) {
                  return null;
                }
                final item = DragItem(
                  localData: 'image-item',
                  suggestedName: 'image.png',
                );
                var imageFile =
                    await editController.fileManager.getImageFile(element.id);
                if (imageFile == null) {
                  return item;
                }
                var bytes = await File(imageFile).readAsBytes();
                // item.add(Formats.png(await createImageData(Colors.green)));
                item.add(Formats.png(bytes));
                return item;
              },
              allowedOperations: () {
                return [DropOperation.copy];
              },
              child: DraggableWidget(
                child: MouseRegion(
                  cursor: MaterialStateMouseCursor.clickable,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (showPopup) {
                        return;
                      }
                      if (!editController.isMobile) {
                        showPopup = true;
                        await showImageViewer(context, [
                          MultiSourceFileImage(
                              imageId: element.id,
                              reader: (id) async {
                                //如何判断图片是否加载完毕？
                                //图片类型是什么？jpg？png？
                                //图片的真实路径是什么
                                var imageFile = await editController.fileManager
                                    .getImageFile(element.id);
                                if (imageFile == null) {
                                  return Uint8List(0);
                                }
                                return File(imageFile).readAsBytes();
                              }),
                        ]);
                        Timer.periodic(const Duration(milliseconds: 200),
                            (timer) {
                          timer.cancel();
                          showPopup = false;
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(padding),
                      width: imageWidth,
                      height: imageHeight,
                      child: OctoImage(
                        color: isSelected
                            ? Colors.blueAccent.withOpacity(0.4)
                            : null,
                        colorBlendMode: isSelected ? BlendMode.darken : null,
                        width: element.width.toDouble(),
                        height: element.height.toDouble(),
                        placeholderBuilder: (context) => Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Container(
                              width: min(100, min(width, height)),
                              height: min(100, min(width, height)),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                        image: MultiSourceFileImage(
                            imageId: element.id,
                            reader: (id) async {
                              //如何判断图片是否加载完毕？
                              //图片类型是什么？jpg？png？
                              //图片的真实路径是什么
                              var imageFile = await editController.fileManager
                                  .getImageFile(element.id);
                              if (imageFile == null) {
                                return Uint8List(0);
                              }
                              return File(imageFile).readAsBytes();
                            }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> createImageData(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = color;
    canvas.drawOval(const Rect.fromLTWH(0, 0, 200, 200), paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(200, 200);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  Future<void> showImageViewerModal(BuildContext context) async {
    var controller = ModalController.of(context);
    await controller?.showModal(
      (ctx) {
        return GestureDetector(
          onTap: () {
            controller.pop();
          },
          child: Container(
            padding: const EdgeInsets.all(50),
            color: Colors.black.withOpacity(0.8),
            child: GestureDetector(
              onTap: () {
                controller.pop();
              },
              child: Center(
                child: OctoImage(
                  // width: element.width.toDouble(),
                  // height: element.height.toDouble(),
                  placeholderBuilder: (context) => Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        width: min(100, min(width, height)),
                        height: min(100, min(width, height)),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  image: MultiSourceFileImage(
                      imageId: element.id,
                      reader: (id) async {
                        var imageFile = await editController.fileManager
                            .getImageFile(element.id);
                        if (imageFile == null) {
                          return Uint8List(0);
                        }
                        return File(imageFile).readAsBytes();
                      }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  int get length => delete ? 0 : 1;

  @override
  WenElement copyElement(TextPosition start, TextPosition end) {
    if (delete) {
      return WenTextElement();
    }
    if (end.offset == 1 && start.offset == 0) {
      return element.copy();
    }
    return WenTextElement();
  }

  @override
  int deletePosition(TextPosition textPosition) {
    int len = length;
    if (textPosition.offset == 1) {
      delete = true;
      relayoutFlag = true;
    }
    return len - length;
  }

  @override
  void deleteRange(TextPosition start, TextPosition end) {
    if (end.offset == 1 && start.offset == 0) {
      delete = true;
      relayoutFlag = true;
    }
  }

  @override
  List<TextBox> getBoxesForSelection(TextSelection selection) {
    int start = selection.baseOffset;
    int end = selection.extentOffset;
    var alignment = calcAlignment();
    var offset = calcAlignmentOffset(
        Size(imageWidth + padding * 2, imageHeight + padding * 2), alignment);
    offset = offset.translate(calcIndentWidth(), 0);
    if (start == 0 && end == 1) {
      return [
        TextBox.fromLTRBD(offset.dx + padding, offset.dy + padding, imageWidth,
            imageHeight, TextDirection.ltr)
      ];
    }
    return [];
  }

  @override
  Rect? getCursorRect(TextPosition textPosition) {
    var alignment = calcAlignment();
    var offset = calcAlignmentOffset(
        Size(imageWidth + padding * 2, imageHeight + padding * 2), alignment);
    offset = offset.translate(calcIndentWidth(), 0);
    if (delete || textPosition.offset == 0) {
      return Rect.fromLTWH(
          offset.dx + padding - 1, offset.dy + padding, 1, imageHeight);
    } else {
      return Rect.fromLTWH(imageWidth + offset.dx + padding - 1,
          offset.dy + padding, 1, imageHeight);
    }
  }

  @override
  TextRange? getWordBoundary(TextPosition textPosition) {
    return const TextRange(start: 0, end: 1);
  }

  @override
  TextPosition? getPositionForOffset(Offset offset) {
    var alignment = calcAlignment();
    var calcOffset = calcAlignmentOffset(
        Size(imageWidth + padding * 2, imageHeight + padding * 2), alignment);
    calcOffset = calcOffset.translate(calcIndentWidth(), 0);

    if (delete || offset.dx <= calcOffset.dx + imageWidth / 2) {
      return const TextPosition(offset: 0);
    } else {
      return const TextPosition(offset: 1);
    }
  }

  @override
  void inputText(EditController controller, TextEditingValue text,
      {bool isComposing = false}) {}

  @override
  void layout(BuildContext context, Size viewSize) {
    this.context = context;
    var mq = MediaQuery.of(context);
    var ratio = mq.devicePixelRatio;
    if (ratio <= 0) {
      ratio = 1;
    }
    var w = element.width;
    var h = element.height;
    var viewMaxImageHeight = (viewSize.width - padding * 2) * h / w;
    // var windowMaxImageHeight = ui.window.physicalSize.height / ratio * 0.6;
    var maxImageHeight = viewMaxImageHeight;
    var imageHeight = h / ratio;
    if (imageHeight < maxImageHeight) {
      height = imageHeight + padding * 2;
    } else {
      imageHeight = maxImageHeight;
      height = maxImageHeight + padding * 2;
    }

    this.imageHeight = imageHeight;
    imageWidth = imageHeight * w / h;
    width = viewSize.width;
  }

  @override
  WenBlock? mergeBlock(WenBlock endBlock) {
    return null;
  }

  @override
  WenBlock splitBlock(TextPosition textPosition) {
    return TextBlock(
      context: context,
      textElement: WenTextElement(),
      editController: editController,
    );
  }

  @override
  ui.TextRange? getLineBoundary(ui.TextPosition textPosition) {
    return getWordBoundary(textPosition);
  }

  @override
  void visitElement(
      TextPosition start, TextPosition end, WenElementVisitor visit) {
    if (start.offset == 0 && end.offset == 1) {
      visit.call(this, element);
    }
  }
}
