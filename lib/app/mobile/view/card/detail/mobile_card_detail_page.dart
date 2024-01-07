import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:note/app/mobile/theme/mobile_theme.dart';
import 'package:note/app/mobile/view/card/detail/mobile_card_detail_controller.dart';
import 'package:note/commons/mvc/view.dart';
import 'package:note/commons/widget/stickey_widget.dart';
import 'package:note/editor/widget/drop_menu.dart';
import 'package:note/editor/widget/toggle_item.dart';
import 'package:note/model/note/vo/xy_item.dart';

import 'mobile_card_detail_model.dart';

class MobileCardDetailPage extends MvcView<MobileCardDetailController> {
  const MobileCardDetailPage({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    var bottomInsert = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: MobileTheme.of(context).mobileBgColor,
            child: buildAppBody(context),
          ),
          if (bottomInsert == 0)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      // blurStyle: BlurStyle.outer,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Color.fromARGB(255, 80, 0, 0)
                          : Color.fromARGB(255, 255, 0, 0),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ToggleItem(
                        onTap: (ctx) {
                          //开始学习
                          createCard(ctx);
                        },
                        itemBuilder: (BuildContext context, bool checked,
                            bool hover, bool pressed) {
                          var color = (hover || pressed)
                              ? Colors.green
                              : const Color.fromARGB(255, 0, 155, 0);
                          return Container(
                            height: 48,
                            color: color,
                            alignment: Alignment.center,
                            child: Text("创建卡片"),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ToggleItem(
                        onTap: (ctx) {
                          //开始学习
                          controller.openCardStudy();
                        },
                        itemBuilder: (BuildContext context, bool checked,
                            bool hover, bool pressed) {
                          var color = (hover || pressed)
                              ? Colors.red
                              : const Color.fromARGB(255, 200, 0, 0);
                          return Container(
                            height: 48,
                            color: color,
                            alignment: Alignment.center,
                            child: Text("开始学习"),
                          );
                        },
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

  SliverAppBar buildSliverAppBar(BuildContext context) {
    const appbarHeight = 48.0;
    const searchBarHeight = 56.0;
    return SliverAppBar(
      title: Obx(() => Text(controller.title)),
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(
          Icons.arrow_back,
          size: 20,
        ),
      ),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
                onPressed: () {
                  showCardSetMenu(context);
                },
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                ));
          }
        ),
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
                margin: EdgeInsets.only(top: 10, left: 16, right: 16),
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

  Widget buildAppBody(BuildContext context) {
    return buildCardSetDetail(context);
  }

  Widget buildCardSetDetail(BuildContext context) {
    return Obx(() {
      return CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          buildSliverAppBar(context),
          SliverPadding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
            sliver: SliverToBoxAdapter(
              child: buildStudyGraphx(context),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            sliver: buildCardListTitle(context),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            sliver: buildCardList(),
          ),
        ],
      );
    });
  }

  Widget buildCardListTitle(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyWidgetDelegate(
        height: 40,
        child: Material(
          color: MobileTheme.of(context).mobileBgColor,
          child: Container(
            height: 40,
            child: Obx(() {
              return CustomTabBar(
                initialIndex: 0,
                onChanged: (index) {
                  controller.tabIndex.value = index;
                },
                tabs: [
                  Tab(
                    text: "今日学习(${controller.todayCardList.length})",
                  ),
                  Tab(
                    text: "待复习(${controller.reviewCardList.length})",
                  ),
                  Tab(
                    text: "全部(${controller.allCardList.length})",
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget buildSearchEdit(BuildContext context) {
    return Obx(
      () => TextField(
        cursorColor: MobileTheme.of(context).cursorColor,
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        onTapOutside: (point) {
          controller.searchFocusNode.unfocus();
        },
        onChanged: (text) {
          controller.searchText.value = text;
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
                    controller.searchText.value = "";
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

  Widget buildCardList() {
    var cardList = controller.todayCardList;
    if (controller.tabIndex.value == 1) {
      cardList = controller.reviewCardList;
    }
    if (controller.tabIndex.value == 2) {
      cardList = controller.allCardList;
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return buildCardItemContent(context, cardList[index],
                cardList[index].buildEditWidget(context));
          },
          childCount: cardList.length,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 200,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
      ),
    );
  }

  Widget buildCardItemContent(
      BuildContext context, CardSearchResultVO searchItem, Widget editWidget) {
    return ToggleItem(
      onTap: (ctx) {
        controller.openCard(searchItem.card);
      },
      onSecondaryTap: (ctx, event) {
        showCardItemContextMenu(context, searchItem, event.globalPosition);
      },
      itemBuilder:
          (BuildContext context, bool checked, bool hover, bool pressed) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: MobileTheme.of(context).fontColor.withOpacity(0.1),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(4),
            color: (hover
                ? MobileTheme.of(context).bgColor3.withOpacity(0.8)
                : MobileTheme.of(context).bgColor3),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(child: IgnorePointer(child: editWidget)),
              // buildNoteTitleInfo(context, searchItem),
            ],
          ),
        );
      },
    );
  }

  void showCardItemContextMenu(
      BuildContext context, CardSearchResultVO card, Offset globalPosition) {
    showMouseDropMenu(
      context,
      globalPosition & const Size(4, 4),
      menus: [
        DropMenu(
          text: Text("编辑"),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.openCard(card.card);
          },
        ),
        DropSplit(),
        DropMenu(
          text: Text(
            "删除",
          ),
          onPress: (ctx) {
            hideDropMenu(ctx);
            controller.deleteCard(card.card);
          },
        ),
      ],
    );
  }

  Widget buildStudyGraphx(BuildContext context) {
    return Obx(() {
      var reviewSpots = getSpots(controller.reviewCountGraphx, "复习数量");
      var studySpots = getSpots(controller.studyCountGraphx, "学习数量");
      var studyTimeSpots = getSpots(controller.studyTimeGraphx, "耗时");
      var maxReviewY = controller.reviewCountGraphx.isEmpty
          ? 0
          : controller.reviewCountGraphx
              .map((element) => element.y ?? 0)
              .reduce((value, element) => max(value, element));
      var maxStudyY = controller.studyCountGraphx.isEmpty
          ? 0
          : controller.studyCountGraphx
              .map((element) => element.y ?? 0)
              .reduce((value, element) => max(value, element));
      var maxY = max(maxReviewY, maxStudyY);
      var n = (maxY * 1.1).round();
      n -= n % 10;
      n += 10;
      return Container(
        height: 260,
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Container(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "学习统计",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  maxY: n.toDouble(),
                  borderData: FlBorderData(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                      ),
                      left: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: reviewSpots,
                      color: Colors.red.shade300,
                      // isCurved: true,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: true,
                      ),
                    ),
                    LineChartBarData(
                      spots: studySpots,
                      color: Colors.green.shade300,
                      // isCurved: true,
                      isStrokeCapRound: false,
                      dotData: const FlDotData(
                        show: true,
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: studySpots.length <= 7
                            ? 1
                            : (studySpots.length / 4).roundToDouble(),
                        getTitlesWidget: (value, meta) {
                          if (controller.studyCountGraphx.isEmpty) {
                            return Text("");
                          }
                          if (value >= controller.studyCountGraphx.length) {
                            return Text("");
                          }
                          if (value == controller.studyCountGraphx.length - 1) {
                            return Text("今天");
                          }
                          return Text(
                              "${controller.studyCountGraphx[value.round()].x}");
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        getTitlesWidget: (value, mate) {
                          return SizedBox(
                            width: 20,
                          );
                        },
                        showTitles: true,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(
                      getTitlesWidget: (value, mate) {
                        return SizedBox(
                          width: 20,
                        );
                      },
                    )),
                  ),
                  lineTouchData: LineTouchData(
                    touchSpotThreshold: 1000,
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      showOnTopOfTheChartBoxArea: true,
                      getTooltipItems: (spots) {
                        var result = getLineTooltipItem(spots, studyTimeSpots);
                        var index = spots.first.spotIndex;
                        var time = studyTimeSpots[index].y;
                        final textStyle = TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        );
                        // result.add(LineTooltipItem(
                        //     "用时:  ${(time / 1000 / 60).toStringAsPrecision(2)}分钟",
                        //     textStyle));
                        return result;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<LineTooltipItem> getLineTooltipItem(
      List<LineBarSpot> touchedSpots, List<FlSpot> studyTimeSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final textStyle = TextStyle(
        color: touchedSpot.bar.gradient?.colors.first ??
            touchedSpot.bar.color ??
            Colors.blueGrey,
        fontSize: 14,
      );
      var spotItem = touchedSpot.bar.spots[touchedSpot.spotIndex];
      if (spotItem is! LabelBot) {
        return LineTooltipItem(spotItem.y.round().toString(), textStyle);
      }
      var index = touchedSpot.spotIndex;
      var time = studyTimeSpots[index].y;
      return LineTooltipItem(
          "${spotItem.label}: ${touchedSpot.y.round().toString()}", textStyle,
          children: [
            if (spotItem.label == "学习数量")
              TextSpan(
                  text:
                      "\n\n用时:  ${(time / 1000 / 60).toStringAsPrecision(2)}分钟",
                  style: TextStyle(
                    color: Colors.white,
                  ))
          ]);
    }).toList();
  }

  List<FlSpot> getSpots(List<XYItem<String, int>> items, String label) {
    List<FlSpot> studySpots = [];
    bool isSkipZero = true;
    for (var i = 0; i < items.length; i++) {
      var y = items[i].y?.toDouble() ?? 0;
      if (y == 0 &&
          (isSkipZero && i < controller.studyCountGraphx.length - 7)) {
        continue;
      }
      isSkipZero = false;
      var spot = LabelBot(
        i.toDouble(),
        y,
        label,
      );
      studySpots.add(spot);
    }
    return studySpots;
  }

  void createCard(BuildContext context) {
    //创建卡片
    controller.createCard();
  }

  void showContextMenu(BuildContext context) {
    showDropMenu(
      context,
      margin: 4,
      menus: [
        DropMenu(
            text: Text("学习设置"),
            onPress: (ctx) {
              hideDropMenu(ctx);
              controller.openCardConfig();
            })
      ],
    );
  }

  void showCardSetMenu(BuildContext context) {
    showDropMenu(
      context,
      modal: true,
      childrenHeight: 48,
      offset: Offset(-10, 0),
      menus: [
        DropMenu(
          text: Text("学习设置"),
          onPress: (context) {
            hideDropMenu(context);
            controller.openCardConfig();
          },
        ),
      ],
    );
  }
}

class CustomTabBar extends StatefulWidget {
  final List<Tab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    this.initialIndex = 0,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with fluent.SingleTickerProviderStateMixin {
  TabController? tabController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      labelColor: MobileTheme.of(context).fontColor,
      tabs: widget.tabs,
      isScrollable: false,
      labelPadding: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 10,
      ),
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      indicatorSize: TabBarIndicatorSize.label,
      onTap: (index) {
        widget.onChanged?.call(index);
      },
    );
  }
}

class LabelBot extends FlSpot {
  final String label;

  LabelBot(super.x, super.y, this.label);
}
