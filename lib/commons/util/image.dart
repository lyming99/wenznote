import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

class ImageSize {
  int width;
  int height;

  ImageSize({required this.width, required this.height});
}

int readImageWidth(ImageInput input) {
  return ImageSizeGetter.getSize(input).width;
}

int readImageHeight(ImageInput input) {
  return ImageSizeGetter.getSize(input).height;
}

ImageSize readImageSize(ImageInput input) {
  var size = ImageSizeGetter.getSize(input);
  return ImageSize(width: size.width, height: size.height);
}

final _decoders = [
  const GifDecoder(),
  const JpegDecoder(),
  const WebpDecoder(),
  const PngDecoder(),
  const BmpDecoder(),
];

bool isValidImage(ImageInput input) {
  for (var value in _decoders) {
    if (value.isValid(input)) {
      return true;
    }
  }
  return false;
}

Future<ImageSize> readImageFileSize(String file) async{
  try {
    var size = ImageSizeGetter.getSize(FileInput(File(file)));
    return ImageSize(width: size.width, height: size.height);
  } catch (e) {
    var image = await decodeImageFromList(File(file).readAsBytesSync());
    return ImageSize(width: image.width, height: image.height);
  }
}


Future createImageFromWidget(Widget widget) {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  final RenderView renderView = RenderView(
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
        size: ui.window.physicalSize,
        devicePixelRatio: ui.window.devicePixelRatio),
    view: ui.window,
  );

  final PipelineOwner pipelineOwner = PipelineOwner()..rootNode = renderView;
  renderView.prepareInitialFrame();
  final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: IntrinsicHeight(child: IntrinsicWidth(child: widget)),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner
    ..buildScope(rootElement)
    ..finalizeTree();
  pipelineOwner
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();
  return repaintBoundary
      .toImage(pixelRatio: ui.window.devicePixelRatio)
      .then((image) => image.toByteData(format: ui.ImageByteFormat.png))
      .then((byteData) => byteData?.buffer.asUint8List());
}
