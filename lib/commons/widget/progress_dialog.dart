import 'package:flutter/material.dart';

const _DefaultDecoration = BoxDecoration(
  color: Colors.white,
  shape: BoxShape.rectangle,
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class ProgressDialog extends StatefulWidget {

  /// Dialog will be closed when [future] task is finished.
  @required
  final Function onInit;

  /// [BoxDecoration] of [ProgressDialog].
  final BoxDecoration? decoration;

  /// opacity of [ProgressDialog]
  final double opacity;

  /// If you want to use custom progress widget set [progress].
  final Widget? progress;

  /// If you want to use message widget set [message].
  final Widget? message;

  const ProgressDialog(
      this.onInit, {
        this.decoration,
        this.opacity = 1.0,
        this.progress,
        this.message,
      });

  @override
  _ProgressDialogState createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {

  @override
  void initState() {
    super.initState();
    widget.onInit.call();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() {
          return false;
        });
      },
      child: _buildDialog(context),
    );
  }

  Widget _buildDialog(BuildContext context) {
    Widget content;
    if (widget.message == null) {
      content = Center(
        child: Container(
          height: 100,
          width: 100,
          alignment: Alignment.center,
          decoration: widget.decoration ?? _DefaultDecoration,
          child: widget.progress ?? const CircularProgressIndicator(),
        ),
      );
    } else {
      content = Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: widget.decoration ?? _DefaultDecoration,
        child:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          widget.progress ?? const CircularProgressIndicator(),
          const SizedBox(width: 20),
          _buildText(context)
        ]),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Opacity(
        opacity: widget.opacity,
        child: content,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    if (widget.message == null) {
      return const SizedBox.shrink();
    }
    return Expanded(
      flex: 1,
      child: widget.message!,
    );
  }
}
