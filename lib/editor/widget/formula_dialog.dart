import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_math_fork/ast.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_math_fork/tex.dart';
import 'package:note/commons/util/platform_util.dart';
import 'package:note/commons/util/widget_util.dart';
import 'package:note/editor/theme/theme.dart';

class FormulaWidget extends StatefulWidget {
  String? title;
  String? formula;

  FormulaWidget({
    Key? key,
    this.title,
    this.formula,
  }) : super(key: key);

  @override
  State<FormulaWidget> createState() => _FormulaState();
}

class _FormulaState extends State<FormulaWidget> {
  String? formula;
  double height = 30;
  SyntaxTree? ast;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    formula = widget.formula;
    controller.text = formula ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      constraints: isMobile
          ? const BoxConstraints(maxWidth: 300)
          : fluent.kDefaultContentDialogConstraints,
      title: fluent.Text(widget.title ?? "输入公式"),
      content: fluent.Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          fluent.Container(
            margin: const EdgeInsets.only(bottom: 10, top: 10),
            child: fluent.TextBox(
              placeholder: "请输入公式",
              controller: controller,
              maxLines: null,
              autofocus: false,
              onSubmitted: (s) {},
              onChanged: (text) {
                setState(() {
                  formula = text;
                });
              },
            ),
          ),
          Container(
              width: double.infinity,
              height: height,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                scrollDirection: Axis.horizontal,
                child: Builder(builder: (context) {
                  var item = Math.tex(
                    formula ?? "",
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: EditTheme.of(context).fontColor,
                    ),
                  );
                  ast = item.ast;
                  if (item.parseError != null) {
                    return const Center(
                      child: Text(
                        "error.",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  var size = calcWidgetSize(
                    item,
                    maxSize: const Size(1000, 1000),
                    context: context,
                  );
                  var height = min(200.0, max(30.0, size.height));
                  if (height != this.height) {
                    WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
                      setState(() {
                        this.height = height;
                      });
                    });
                    return Container();
                  }
                  return Center(child: item);
                }),
              )),
        ],
      ),
      actions: [
        fluent.Button(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context, null);
            // Delete file here
          },
        ),
        fluent.FilledButton(
            onPressed: () {
              Navigator.pop(context, {
                "formula": formula,
                "ok": true,
              });
            },
            child: const Text("确定")),
      ],
    );
  }
}
