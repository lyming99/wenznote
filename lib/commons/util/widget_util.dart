import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<ui.Image> widgetToUiImage(
  Widget widget, {
  Duration delay: const Duration(seconds: 1),
  double? pixelRatio,
  BuildContext? context,
  Size? targetSize,
}) async {
  ///
  ///Retry counter
  ///
  int retryCounter = 3;
  bool isDirty = false;

  Widget child = widget;

  if (context != null) {
    child = InheritedTheme.captureAll(
      context,
      MediaQuery(
          data: MediaQuery.of(context),
          child: Material(
            child: child,
            color: Colors.transparent,
          )),
    );
  }

  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  Size logicalSize = targetSize ??
      ui.window.physicalSize / ui.window.devicePixelRatio; // Adapted
  Size imageSize = targetSize ?? ui.window.physicalSize; // Adapted

  assert(logicalSize.aspectRatio.toStringAsPrecision(5) ==
      imageSize.aspectRatio
          .toStringAsPrecision(5)); // Adapted (toPrecision was not available)

  final RenderView renderView = RenderView(
    view: ui.window,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: pixelRatio ?? 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(
      focusManager: FocusManager(),
      onBuildScheduled: () {
        ///
        ///current render is dirty, mark it.
        ///
        isDirty = true;
      });

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
          container: repaintBoundary,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: child,
          )).attachToRenderTree(
    buildOwner,
  );
  ////

  buildOwner.buildScope(
    rootElement,
  );
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();
  ui.Image? image;
  do {
    ///
    ///Reset the dirty flag
    ///
    ///
    isDirty = false;

    image = await repaintBoundary.toImage(
        pixelRatio: pixelRatio ?? (imageSize.width / logicalSize.width));

    ///
    ///This delay sholud increas with Widget tree Size
    ///

    await Future.delayed(delay);

    ///
    ///Check does this require rebuild
    ///
    ///
    if (isDirty) {
      ///
      ///Previous capture has been updated, re-render again.
      ///
      ///
      buildOwner.buildScope(
        rootElement,
      );
      buildOwner.finalizeTree();
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();
    }
    retryCounter--;

    ///
    ///retry untill capture is successfull
    ///
  } while (isDirty && retryCounter >= 0);
  try {
    /// Dispose All widgets
    rootElement.visitChildren((Element element) {
      rootElement.deactivateChild(element);
    });
    buildOwner.finalizeTree();
  } catch (e) {}

  return image; // Adapted to directly return the image and not the Uint8List
}

Size calcWidgetSize(
  Widget widget, {
  Size? maxSize,
  BuildContext? context,
}) {
  var startTime = DateTime.now().millisecondsSinceEpoch;
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
  Size logicalSize = maxSize ??
      (ui.window.physicalSize / ui.window.devicePixelRatio); // Adapted
  final RenderView renderView = RenderView(
    view: ui.window,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: 1.0,
    ),
  );

  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner(
    focusManager: FocusManager(),
  );
  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();
  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: widget,
    ),
  ).attachToRenderTree(
    buildOwner,
  );
  buildOwner.buildScope(
    rootElement,
  );
  pipelineOwner.flushLayout();
  print(
      'calc widget size use time:${DateTime.now().millisecondsSinceEpoch - startTime}ms');
  return repaintBoundary.size;
}
