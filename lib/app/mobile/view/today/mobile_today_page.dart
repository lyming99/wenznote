import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:note/app/mobile/theme/mobile_theme.dart';
import 'package:note/app/mobile/view/user/mobile_user_icon.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/model/note/enum/note_order_type.dart';

import 'mobile_today_controller.dart';

/// 搜索>>跳转到搜索全部界面
/// 列表：显示最近的日记、便签、笔记
/// 排序：按创建时间排序、按记忆曲线排序
class MobileTodayPageWidget extends MvcView<MobileTodayController> {
  const MobileTodayPageWidget({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:MobileTheme.of(context).mobileBgColor,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          buildSliverAppBar(context),
          buildFilterWidget(context),
          buildDocList(context),
        ],
      ),
    );
  }

  SliverPadding buildDocList(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      sliver: Obx(
        () {
          var showList = controller.showList;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Obx(() {
                  var docModel = showList[index];
                  return InkWell(
                    onTap: () {
                      var docModel = showList[index];
                      controller.openDoc(docModel);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 6,
                        bottom: 6,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: MobileTheme.of(context).bgColor3,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              docModel.buildEditWidget(context),
                              Container(
                                height: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: MobileTheme.of(context).bgColor3,
                                  boxShadow: [
                                    BoxShadow(
                                      color: MobileTheme.buildColor(context,
                                          darkColor:
                                              Colors.black.withOpacity(0.2),
                                          lightColor:
                                              Colors.grey.withOpacity(0.2))!,
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 40,
                                color: MobileTheme.of(context).bgColor3,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      docModel.getTypeTitle(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: MobileTheme.of(context)
                                            .fontColor
                                            .withOpacity(0.4),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Obx(
                                        () => Text(
                                          docModel.getTimeString(
                                              controller.orderParam.value),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: MobileTheme.of(context)
                                                .fontColor
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Builder(builder: (context) {
                                      return fluent.IconButton(
                                        onPressed: () {
                                          //显示菜单
                                          showDropMenu(
                                            context,
                                            menus: [
                                              DropMenu(
                                                height: 48,
                                                icon: const Icon(
                                                  Icons.copy,
                                                ),
                                                text: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: const Text("复制内容"),
                                                ),
                                                onPress: (context) {
                                                  Navigator.of(context).pop();
                                                  controller.copy(
                                                      context, index);
                                                },
                                              ),
                                              if (docModel.doc.type != "doc")
                                                DropMenu(
                                                  height: 48,
                                                  icon: const Icon(
                                                    Icons
                                                        .drive_file_move_outline,
                                                  ),
                                                  text: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: const Text("存到笔记"),
                                                  ),
                                                  onPress: (context) {
                                                    Navigator.of(context).pop();
                                                    controller.saveToDocTree(
                                                        context, index);
                                                  },
                                                ),
                                              DropMenu(
                                                height: 48,
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.redAccent,
                                                ),
                                                text: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: const Text(
                                                    "删除",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.redAccent),
                                                  ),
                                                ),
                                                onPress: (context) {
                                                  Navigator.of(context).pop();
                                                  controller.delete(
                                                      context, index);
                                                },
                                              ),
                                            ],
                                            modal: true,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.more_horiz_outlined,
                                          size: 16,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
              childCount: showList.length,
            ),
          );
        },
      ),
    );
  }

  SliverAppBar buildSliverAppBar(BuildContext context) {
    const appbarHeight = 48.0;
    const searchBarHeight = 56.0;
    return SliverAppBar(
      title: Text(
        "今天",
        style: TextStyle(color: MobileTheme.of(context).fontColor),
      ),
      leading: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: MobileUserIcon(),
      ),
      actions: [
        IconButton(
            onPressed: () {
              controller.createNote();
            },
            icon: Icon(
              Icons.add,
              size: 32,
            )),
      ],
      titleSpacing: 0,
      toolbarHeight: appbarHeight,
      backgroundColor: MobileTheme.of(context).mobileBgColor,
      shadowColor: Colors.transparent,
      foregroundColor: MobileTheme.of(context).fontColor,
      systemOverlayStyle: MobileTheme.overlayStyle(context),
      floating: true,
      snap: false,
      pinned: true,
      expandedHeight: appbarHeight + searchBarHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 40,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: MobileTheme.of(context).mobileContentBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: buildSearchEdit(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildSearchEdit(BuildContext context) {
    return Obx(
      () => TextField(
        focusNode: controller.searchFocusNode,
        controller: controller.searchController,
        cursorColor: MobileTheme.of(context).cursorColor,
        onTapOutside: (point) {
          controller.searchFocusNode.unfocus();
        },
        onChanged: (text) {
          controller.doSearch(text);
        },
        style: TextStyle(
          height: 1,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(maxWidth: 40),
          suffixIconConstraints: BoxConstraints(maxWidth: 40),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: MobileTheme.of(context).fontColor.withOpacity(0.3),
            size: 24,
          ),
          suffixIcon: controller.searchText.isEmpty
              ? null
              : GestureDetector(
                  onTap: () {
                    controller.searchController.clear();
                    controller.searchFocusNode.unfocus();
                  },
                  child: Icon(
                    Icons.highlight_remove_outlined,
                    color: MobileTheme.of(context).fontColor.withOpacity(0.3),
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          hintText: "搜索",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          hintMaxLines: 1,
        ),
      ),
    );
  }

  Widget buildFilterWidget(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
          child: PreferredSize(
        preferredSize: Size(double.infinity, 40),
        child: Container(
          height: 48,
          color: MobileTheme.of(context).mobileBgColor,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Builder(builder: (context) {
            return Row(
              children: [
                Builder(builder: (context) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showDropMenu(
                          context,
                          menus: [
                            DropMenu(
                              height: 48,
                              text: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Obx(
                                  () => Row(
                                    children: [
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.orderType.value =
                                                  OrderType.asc;
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: IgnorePointer(
                                              child: fluent.Checkbox(
                                                checked: (controller
                                                        .orderType.value ==
                                                    OrderType.asc),
                                                content: Text("升序"),
                                                onChanged: (val) {},
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.orderType.value =
                                                  OrderType.desc;
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: IgnorePointer(
                                              child: fluent.Checkbox(
                                                checked: (controller
                                                        .orderType.value ==
                                                    OrderType.desc),
                                                content: Text("降序"),
                                                onChanged: (val) {},
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            DropMenu(
                              height: 48,
                              text: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Obx(
                                  () => Row(
                                    children: [
                                      const Expanded(child: Text("按修改时间")),
                                      if (controller.orderParam.value ==
                                          OrderProperty.updateTime)
                                        const Icon(Icons.check),
                                    ],
                                  ),
                                ),
                              ),
                              onPress: (context) {
                                controller.orderParam.value =
                                    OrderProperty.updateTime;
                                Navigator.of(context).pop();
                              },
                            ),
                            DropMenu(
                              height: 48,
                              text: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Obx(
                                  () => Row(
                                    children: [
                                      const Expanded(child: Text("按创建时间")),
                                      if (controller.orderParam.value ==
                                          OrderProperty.createTime)
                                        const Icon(Icons.check),
                                    ],
                                  ),
                                ),
                              ),
                              onPress: (context) {
                                controller.orderParam.value =
                                    OrderProperty.createTime;
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                          modal: true,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort),
                          Obx(() => Text(controller.orderParam.value ==
                                  OrderProperty.updateTime
                              ? "按修改时间"
                              : "按创建时间")),
                          Icon(Icons.arrow_drop_down_outlined),
                        ],
                      ),
                    ),
                  );
                }),
                Expanded(child: Container()),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      controller.fetchDoc();
                    },
                    child: Container(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.refresh_outlined)),
                  ),
                ),
                Builder(builder: (context) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showDropMenu(
                            context,
                            menus: [
                              DropMenu(
                                height: 48,
                                text: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Obx(
                                    () => Row(
                                      children: [
                                        const Expanded(child: Text("便签")),
                                        if (controller.showNote.isTrue)
                                          const Icon(Icons.check),
                                      ],
                                    ),
                                  ),
                                ),
                                onPress: (context) {
                                  controller.showNote.toggle();
                                },
                              ),
                              DropMenu(
                                height: 48,
                                text: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Obx(
                                    () => Row(
                                      children: [
                                        const Expanded(child: Text("笔记")),
                                        if (controller.showDoc.isTrue)
                                          const Icon(Icons.check),
                                      ],
                                    ),
                                  ),
                                ),
                                onPress: (context) {
                                  controller.showDoc.toggle();
                                },
                              ),
                            ],
                            modal: true,
                          );
                        },
                        child: Container(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.filter_alt_outlined)),
                      ),
                    ),
                  );
                }),
              ],
            );
          }),
        ),
      )),
    );
  }

  Widget buildDiaryNoteWidget(BuildContext context) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          Container(
            height: 80,
            margin: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: fluent.Colors.grey[40],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [],
            ),
          ),
          Positioned(
            left: 20,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MobileTheme.buildColor(
                  context,
                  darkColor: Color(0xff2a2a2a),
                  lightColor: fluent.Colors.grey[10],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    "MAY",
                    style: TextStyle(
                      fontSize: 16,
                      color: fluent.Colors.red.normal,
                    ),
                  ),
                  Text(
                    "21",
                    style: TextStyle(
                      fontSize: 24,
                      color: fluent.Colors.grey[150],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;

  StickyTabBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
