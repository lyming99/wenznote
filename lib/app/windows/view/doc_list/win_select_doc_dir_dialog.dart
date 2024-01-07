import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:note/app/windows/controller/doc_list/win_select_doc_dir_list_controller.dart';
import 'package:note/app/windows/view/doc_list/win_select_doc_list.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:note/model/note/po/doc_dir_po.dart';
import 'package:note/widgets/custom_navgator_observer.dart';

class SelectDocDirDialog extends StatefulWidget {
  final String? openDirId;
  final String? title;
  final String? actionLabel;
  final bool Function(List<DocDirPO> path)? filter;
  final Function(DocDirPO dir)? onSelect;
  final double width;
  final double height;

  const SelectDocDirDialog({
    Key? key,
    this.title,
    this.openDirId,
    this.actionLabel,
    this.filter,
    this.onSelect,
    this.width=400,
    this.height=320,
  }) : super(key: key);

  @override
  State<SelectDocDirDialog> createState() => SelectDocDirDialogState();
}

class SelectDocDirDialogState extends State<SelectDocDirDialog> {
  var controllerMap = <String, WinSelectDocDirListController>{};
  var currentController = Rxn<WinSelectDocDirListController>();

  @override
  Widget build(BuildContext context) {
    return fluent.ContentDialog(
      title: Text("${widget.title}"),
      constraints: BoxConstraints(
        maxWidth: widget.width,
        maxHeight: widget.height,
      ),
      content: buildNavigatorView(context),
      actions: [
        fluent.OutlinedButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Obx(() {
          var canMoveHear = currentController.value?.canMoveHear.value == true;
          return fluent.FilledButton(
            child: Text("${widget.actionLabel ?? "确定"}"),
            onPressed: canMoveHear
                ? () {
                    Navigator.of(context).pop();
                    widget.onSelect
                        ?.call(currentController.value!.pathList.last);
                  }
                : null,
          );
        }),
      ],
    );
  }

  Widget buildNavigatorView(BuildContext context) {
    return Navigator(
      initialRoute: "/",
      observers: [
        CustomNavigatorObserver(
          onPush: (route) {
            currentController.value =
                controllerMap[route?.settings.name ?? "/"];
          },
        )
      ],
      onGenerateRoute: (settings) {
        var controller = WinSelectDocDirListController(
          docDirUuid: settings.name == "/" || settings.name == ""
              ? null
              : settings.name,
          dirFilter: widget.filter,
        );
        controllerMap[settings.name ?? "/"] = controller;
        return PageRouteBuilder(
          settings: settings,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) {
            return buildPage(
                context, animation, secondaryAnimation, controller);
          },
        );
      },
    );
  }

  Widget buildPage(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      WinSelectDocDirListController controller) {
    return MvcView(
      controller: controller,
      builder: (context) {
        return WinSelectDocDirListView(controller: controller);
      },
    );
  }
}
