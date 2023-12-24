import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/home/win_home_controller.dart';
import 'package:note/commons/util/markdown/markdown.dart';
import 'package:note/editor/edit_controller.dart';
import 'package:note/editor/edit_widget.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/service/service_manager.dart';
import 'package:window_manager/window_manager.dart';

class WindowsHelpTab extends StatefulWidget {
  const WindowsHelpTab({Key? key}) : super(key: key);

  @override
  State<WindowsHelpTab> createState() => _WindowsHelpTabState();
}

class _WindowsHelpTabState extends State<WindowsHelpTab> {
  EditController? editController;

  @override
  void initState() {
    super.initState();
    readHelpDoc(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildNav(context),
        Expanded(
          child: buildContent(context),
        ),
      ],
    );
  }

  void closeTab() {
    Get.find<WinHomeController>().closeTab("help_windows");
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
              closeTab();
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
                "温知笔记帮助",
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
    if (editController == null) {
      return Container();
    }
    return EditWidget(controller: editController!);
  }

  void readHelpDoc(BuildContext context) async {
    var serviceManager = ServiceManager.of(context);
    String docMarkdown =
        await rootBundle.loadString("assets/doc/help_windows.md");
    var elements = await parseMarkdown(serviceManager.fileManager,docMarkdown);
    editController = EditController(
      fileManager: serviceManager.fileManager,
      copyService: serviceManager.copyService,
      reader: () async {
        return elements.map((e) => e.toJson()).toList();
      },
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
    );
    setState(() {});
  }
}
