import 'dart:async';

import 'package:flutter/material.dart';

import '../block/block.dart';

class CursorPosition {
  WenBlock? block;
  TextPosition? textPosition;
  Rect? rect;
  int? blockIndex;
  double? blockVisionTop;

  CursorPosition({
    this.blockIndex,
    this.block,
    this.textPosition,
    this.rect,
    this.blockVisionTop,
  });

  bool get isValid => block != null && textPosition != null;

  CursorPosition get copy => CursorPosition(
        block: block,
        textPosition: textPosition,
        rect: rect,
        blockIndex: blockIndex,
        blockVisionTop: blockVisionTop,
      );

  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CursorPosition &&
        other.blockIndex == blockIndex &&
        other.textPosition == textPosition &&
        other.rect == rect;
  }

  bool equalsCursorIndex(CursorPosition? other) {
    if (other == null) {
      return false;
    }
    if (other.blockIndex != blockIndex) {
      return false;
    }
    if (other.textPosition?.offset != textPosition?.offset) {
      return false;
    }
    return true;
  }
}

class CursorState {
  Offset? mouseEventPosition;
  CursorTimer? timer;
  bool freshFlag = false;
  CursorPosition? hoverPosition;

  CursorPosition? cursorPosition;

  CursorState();

  void startCursorTimer(Function callback) {
    stopCursorTimer();
    callback.call();
    timer = CursorTimer(() {
      freshFlag = !freshFlag;
      callback.call();
    });
  }

  void stopCursorTimer() {
    freshFlag = false;
    timer?.cancel();
    timer = null;
  }

  ///光标闪烁
  bool get freshShowing => freshFlag == false;
}

class CursorTimer {
  late Timer timer;
  bool stop = false;

  CursorTimer(Function callback) {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!stop) {
        callback.call();
      }
    });
  }

  void cancel() {
    if (stop) return;
    stop = true;
    timer.cancel();
  }
}
