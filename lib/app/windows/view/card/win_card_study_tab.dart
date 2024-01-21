import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/card/win_card_study_controller.dart';
import 'package:note/app/windows/widgets/card_editor.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:note/editor/crdt/YsEditController.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/service/service_manager.dart';
import 'package:window_manager/window_manager.dart';

class WinCardStudyTab extends MvcView<WinCardStudyController> {
  const WinCardStudyTab({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTapDown: (e) {
              controller.focusNode.requestFocus();
            },
            child: Obx(() {
              return buildContent(context);
            }),
          ),
        ),
      ],
    );
  }

  Widget buildNav(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // drawer button
          ToggleItem(
            onTap: (ctx) {
              controller.closeTab();
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
              );
            },
          ),
          Expanded(
              child: DragToMoveArea(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "学习",
                style: TextStyle(fontSize: 16),
              ),
            ),
          )),
          // actions
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    //学习界面
    //学习内容
    var card = controller.currentCard.value;
    if (card == null) {
      return Container();
    }
    return Focus(
      focusNode: controller.focusNode,
      autofocus: true,
      onKey: (node, event) {
        if (event is! RawKeyDownEvent) {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          controller.recordStudy(0);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          controller.recordStudy(1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          controller.recordStudy(2);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          controller.recordStudy(3);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          CardEditor(
            card: card,
            key: ValueKey(card),
            editController: YsEditController(
              fileManager: ServiceManager.of(context).fileManager,
              copyService: ServiceManager.of(context).copyService,
              initFocus: false,
              editable: false,
              padding: const EdgeInsets.only(
                top: 10,
                left: 20,
                right: 20,
                bottom: 100,
              ),
              scrollController: ScrollController(),
              hideTextModes: controller.hideTextModes,
            ),
            onCardUpdate: (doc) {},
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListenableBuilder(
              listenable: controller.focusNode,
              builder: (BuildContext context, Widget? child) {
                if (!controller.focusNode.hasFocus) {
                  return Container();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToggleItem(
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 80,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "↑简单",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Text(
                                "${controller.time1}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: (ctx) {
                        controller.recordStudy(0);
                      },
                    ),
                    ToggleItem(
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 80,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "←普通",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Text(
                                "${controller.time2}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: (ctx) {
                        controller.recordStudy(1);
                      },
                    ),
                    ToggleItem(
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 80,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "→困难",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Text(
                                "${controller.time3}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: (ctx) {
                        controller.recordStudy(2);
                      },
                    ),
                    ToggleItem(
                      itemBuilder: (BuildContext context, bool checked,
                          bool hover, bool pressed) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 80,
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "↓重复",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              Text(
                                "${controller.time4}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                      onTap: (ctx) {
                        controller.recordStudy(3);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          ListenableBuilder(
              listenable: controller.focusNode,
              builder: (ctx, a) {
                if (controller.hasFocus || controller.focusNode.hasFocus) {
                  return Container();
                }
                return Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Text(
                      "点击此处开始学习",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}
