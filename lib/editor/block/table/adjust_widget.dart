import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/services.dart';

import '../../widget/toggle_item.dart';

typedef TableAdjustCallback = Function(int rowCount, int colCount);

class TableAdjustGridWidget extends StatefulWidget {
  int defaultColCount;
  int defaultRowCount;
  TableAdjustCallback callback;

  TableAdjustGridWidget({
    Key? key,
    required this.defaultColCount,
    required this.defaultRowCount,
    required this.callback,
  }) : super(key: key);

  @override
  State<TableAdjustGridWidget> createState() => _TableAdjustGridWidgetState();
}

class _TableAdjustGridWidgetState extends State<TableAdjustGridWidget> {
  int hoverIndex = -1;
  var rowEditController = TextEditingController();
  var colEditController = TextEditingController();
  var rowFocus = FocusNode();
  var colFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    rowFocus = FocusNode();
    colFocus = FocusNode();
    rowFocus.addListener(() {
      if (rowFocus.hasFocus) {
        updateState();
      }
    });
    colFocus.addListener(() {
      if (colFocus.hasFocus) {
        updateState();
      }
    });
    int rowCount = widget.defaultRowCount;
    int colCount = widget.defaultColCount;
    rowEditController.text = "$rowCount";
    colEditController.text = "$colCount";
  }

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: fluent.Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleItem(
              itemBuilder: (BuildContext context, bool checked, bool hover,
                  bool pressed) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: 60,
                  itemBuilder: (ctx, index) {
                    int row = index ~/ 6;
                    int col = index % 6;
                    var bgColor = Colors.grey.shade300;
                    if (row < widget.defaultRowCount &&
                        col < widget.defaultColCount) {
                      bgColor = Colors.grey;
                    }

                    var color = Colors.white.withOpacity(0);
                    if (hoverIndex >= 0) {
                      int hoverRow = hoverIndex ~/ 6;
                      int hoverCol = hoverIndex % 6;
                      if (row <= hoverRow && col <= hoverCol) {
                        color = Colors.blueAccent.withOpacity(0.2);
                      }
                    }
                    return ToggleItem(
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          color: bgColor,
                          child: Container(
                            color: color,
                          ),
                        );
                      },
                      onHoverEnter: (ctx) {
                        setState(() {
                          hoverIndex = index;
                          rowFocus.unfocus();
                          colFocus.unfocus();
                          int rowCount = widget.defaultRowCount;
                          int colCount = widget.defaultColCount;
                          if (hoverIndex != -1) {
                            rowCount = hoverIndex ~/ 6 + 1;
                            colCount = hoverIndex % 6 + 1;
                          }
                          rowEditController.text = "$rowCount";
                          colEditController.text = "$colCount";
                        });
                      },
                      onTap: (ctx) {
                        widget.callback.call(min(2000, max(1, row + 1)),
                            min(2000, max(1, col + 1)));
                      },
                    );
                  },
                );
              },
              onHoverExit: (ctx) {
                setState(() {
                  int rowCount = widget.defaultRowCount;
                  int colCount = widget.defaultColCount;
                  rowEditController.text = "$rowCount";
                  colEditController.text = "$colCount";
                  hoverIndex = -1;
                });
              },
            ),
          ),
        ),
        fluent.SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 26,
                width: 26,
                child: fluent.TextBox(
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  controller: colEditController,
                  focusNode: colFocus,
                  padding: EdgeInsets.zero,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: fluent.TextInputType.number,
                  inputFormatters: [
                    // 完善的计数输入替代方案
                    CounterTextInputFormatter(min: 1, max: 200),
                  ],
                ),
              ),
              const Icon(
                Icons.close,
              ),
              SizedBox(
                height: 24,
                width: 24,
                child: fluent.TextBox(
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                  controller: rowEditController,
                  focusNode: rowFocus,
                  padding: EdgeInsets.zero,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: fluent.TextInputType.number,
                  inputFormatters: [
                    // 完善的计数输入替代方案
                    CounterTextInputFormatter(min: 1, max: 1000),
                  ],
                ),
              ),
              if (rowFocus.hasFocus || colFocus.hasFocus)
                fluent.Container(
                  margin: const EdgeInsets.only(left: 4),
                  child: fluent.FilledButton(
                    onPressed: () {
                      var rowCount = int.parse(rowEditController.text);
                      var colCount = int.parse(colEditController.text);
                      widget.callback.call(min(2000, max(1, rowCount)),
                          min(2000, max(1, colCount)));
                    },
                    style: fluent.ButtonStyle(
                      padding: fluent.ButtonState.all(
                          const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4)),
                      textStyle: fluent.ButtonState.all(const TextStyle(
                        fontSize: 12,
                      )),
                    ),
                    child: const Text("确定"),
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}

class CounterTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  CounterTextInputFormatter({required this.min, required this.max});

  late final RegExp regExp =
      RegExp(r"^\d{0," "${max.toString().length}" r"}?$");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      var text = min.toString();
      // 全部删除赋值最小值
      return TextEditingValue(
        text: text,
        selection: TextSelection(baseOffset: 0, extentOffset: text.length),
      );
    }
    // 判定 新输入值符合输入预期
    bool isValid = (oldValue.text.length > newValue.text.length) ||
        regExp.hasMatch(newValue.text);

    if (isValid) {
      // 2022.11.30日增加， 从0开始的话增加逻辑代码
      if (newValue.text.startsWith('0')) {
        // 额外增加安全判断。
        int? value = int.tryParse(newValue.text);
        if (value != null) {
          String text = value.toString();

          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        } else {
          return oldValue;
        }
      }

      return newValue;
    }
    return oldValue;
  }
}
