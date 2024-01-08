import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef InputCallback = Function(TextEditingValue value);
typedef InputComposingCallback = Function(TextEditingValue value);
typedef InputStartCallback = Function(TextEditingValue value);
typedef ActionCallback = Function(TextInputAction action);

class InputManager with TextInputClient, DeltaTextInputClient {
  InputManager({
    this.inputCallback,
    this.inputComposingCallback,
    this.actionCallback,
  });

  TextEditingValue? composing;
  InputComposingCallback? inputComposingCallback;
  InputStartCallback? inputStartCallback;
  InputCallback? inputCallback;
  TextInputConnection? connection;
  TextEditingValue? textEditingValue;
  ActionCallback? actionCallback;

  bool get isOpen {
    return connection?.attached == true;
  }

  bool get hasComposing => composing != null && composing!.text.isNotEmpty;

  void openInputMethod() {
    var conn = connection;
    if (conn != null && conn.attached) {
      conn.show();
      return;
    }
    connection?.close();
    connection = TextInput.attach(
      this,
      const TextInputConfiguration(
        inputAction: TextInputAction.newline,
        enableDeltaModel: true,
      ),
    )..setEditingState(const TextEditingValue());
    connection!.show();
  }

  void closeInputMethod() {
    connection?.close();
    connection = null;
  }

  @override
  void connectionClosed() {
    connection = null;
  }

  @override
  AutofillScope? get currentAutofillScope {
    return null;
  }

  @override
  TextEditingValue? get currentTextEditingValue {
    return textEditingValue;
  }

  @override
  void performAction(TextInputAction action) {
    actionCallback?.call(action);
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    print('action:$action');
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @override
  void updateEditingValue(TextEditingValue value) {
    textEditingValue = value;
    if (!value.composing.isValid) {
      if (value.text.isNotEmpty) {
        inputCallback?.call(value);
        connection?.setEditingState(const TextEditingValue());
      } else {
        inputStartCallback?.call(value);
      }
    } else {
      inputComposingCallback?.call(value);
    }
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {}

  void updateInputPosition(
      Size editableSize, Rect? caretRect, Rect? composingRect) {
    if (caretRect != null && composingRect != null) {
      Offset? offset = _snapToPhysicalPixel(caretRect.topLeft);
      if (offset != null) {
        connection?.setCaretRect(caretRect.shift(offset));
        connection?.setComposingRect(composingRect.shift(offset));
      }
      Matrix4? to = getTransformTo();
      if (to != null) {
        connection?.setEditableSizeAndTransform(editableSize, to);
      }
      if (connection?.attached == true) {
        connection?.show();
      }
    }
  }

  BuildContext? context;

  Matrix4? getTransformTo() {
    var render = context?.findRenderObject();
    if (render is RenderBox) {
      return render.getTransformTo(null);
    }
    return null;
  }

  Offset? _snapToPhysicalPixel(Offset sourceOffset) {
    var context = this.context;
    if (context == null) {
      return null;
    }
    var render = context.findRenderObject();
    if (render is RenderBox) {
      final Offset globalOffset = render.localToGlobal(sourceOffset);
      final double pixelMultiple =
          1.0 / MediaQuery.of(context).devicePixelRatio;
      var ret = Offset(
        globalOffset.dx.isFinite
            ? (globalOffset.dx / pixelMultiple).round() * pixelMultiple -
                globalOffset.dx
            : 0,
        globalOffset.dy.isFinite
            ? (globalOffset.dy / pixelMultiple).round() * pixelMultiple -
                globalOffset.dy
            : 0,
      );
      return ret;
    }
    return null;
  }

  @override
  void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
    for (var delta in textEditingDeltas) {
      if (delta is TextEditingDeltaInsertion) {
        inputCallback?.call(TextEditingValue(
          text: delta.textInserted,
          composing: delta.composing,
          selection: delta.selection,
        ));
      }
    }
  }
}
