import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wenznote/app/windows/controller/card/win_card_set_detail_page_controller.dart';
import 'package:wenznote/app/windows/model/card/win_card_search_result_vo.dart';
import 'package:wenznote/commons/mvc/view.dart';
import 'package:wenznote/commons/widget/stickey_widget.dart';
import 'package:wenznote/editor/theme/theme.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:wenznote/model/note/vo/xy_item.dart';
import 'package:window_manager/window_manager.dart';

class WinCardSetDetailPage extends MvcView<WinCardSetDetailPageController> {
  const WinCardSetDetailPage({
    super.key,
    required super.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildCardSetNav(context),
        Expanded(
          child: buildCardSetDetail(context),
        ),
      ],
    );
  }

  Widget buildCardSetNav(BuildContext context) {
    var theme = fluent.FluentTheme.of(context);
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.resources.solidBackgroundFillColorTertiary,
        border: Border(bottom: BorderSide(color: theme.resources.cardStrokeColorDefaultSolid))
      ),
      child: Row(
        children: [
          // title
          Expanded(
            child: DragToMoveArea(
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    // drawer button
                    SizedBox(width: 10,),
                    Text(
                      "${controller.cardSet.title}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // actions
          ToggleItem(
            onTap: (ctx) {
              createCard(context);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.add,
                  size: 22,
                ),
              );
            },
          ),
          // actions
          ToggleItem(
            onTap: (context) {
              showContextMenu(context);
            },
            itemBuilder:
                (BuildContext context, bool checked, bool hover, bool pressed) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.more_horiz_outlined,
                  size: 22,
                ),
              );
            },
          ),
          SizedBox(
            width: 4,
          ),
        ],
      ),
    );
  }

  Widget buildCardSetDetail(BuildContext context) {
    return Container(
      color: fluent.FluentTheme.of(context).resources.solidBackgroundFillColorSecondary,
      child: Obx(() {
        return CustomScrollView(
          slivers: [
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
      }),
    );
  }

  Widget buildCardListTitle(fluent.BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyWidgetDelegate(
        height: 100,
        child: Material(
          color: fluent.FluentTheme.of(context).resources.solidBackgroundFillColorSecondary,
          child: Container(
            margin: EdgeInsets.only(
              top: 10,
              bottom: 10,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: buildSearchEdit(context)),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Obx(() {
                          return CustomTabBar(
                            initialIndex: 0,
                            onChanged: (index) {
                              controller.tabIndex.value = index;
                            },
                            tabs: [
                              Tab(
                                text:
                                    "今日学习(${controller.todayCardList.length})",
                              ),
                              Tab(
                                text:
                                    "待复习(${controller.reviewCardList.length})",
                              ),
                              Tab(
                                text: "全部(${controller.allCardList.length})",
                              ),
                            ],
                          );
                        }),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      fluent.FilledButton(
                        onPressed: () {
                          controller.openCardStudy();
                        },
                        child: Text("开始学习"),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearchEdit(BuildContext context) {
    return Obx(
      () => fluent.TextBox(
        placeholder: "搜索卡片",
        controller: controller.searchController,
        onChanged: (v) {
          controller.searchContent.value = v;
        },
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.search),
        ),
        suffix: controller.searchContent.value.isEmpty
            ? null
            : ToggleItem(
                onTap: (ctx) {
                  controller.searchController.clear();
                  controller.searchContent.value = "";
                },
                itemBuilder: (BuildContext context, bool checked, bool hover,
                    bool pressed) {
                  return Container(
                    color: hover ? Colors.grey.withOpacity(0.1) : null,
                    child: Icon(Icons.close),
                  );
                },
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

  Widget buildCardItemContent(BuildContext context,
      WinCardSearchResultVO searchItem, Widget editWidget) {
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
                color: EditTheme.of(context).fontColor.withOpacity(0.1),
                blurRadius: 1,
                spreadRadius: 1,
              ),
            ],
            borderRadius: BorderRadius.circular(4),
            color: (hover
                ? EditTheme.of(context).bgColor3.withOpacity(0.8)
                : EditTheme.of(context).bgColor3),
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
      BuildContext context, WinCardSearchResultVO card, Offset globalPosition) {
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
        height: 240,
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: fluent.Padding(
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
      labelColor: EditTheme.of(context).fontColor,
      tabs: widget.tabs,
      isScrollable: true,
      labelPadding: EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 10,
      ),
      padding: EdgeInsets.zero,
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
