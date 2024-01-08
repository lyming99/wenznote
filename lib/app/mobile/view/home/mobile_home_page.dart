import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note/app/mobile/theme/mobile_theme.dart';
import 'package:note/service/service_manager.dart';

class MobileHomePage extends StatelessWidget {
  const MobileHomePage({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('MobileHomeWidget'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    var activeColor = MobileTheme.of(context).mobileNavActiveColor;
    var defaultColor =
        MobileTheme.of(context).mobileNavActiveColor.withAlpha(100);
    var backgroundColor = MobileTheme.of(context).mobileNavBgColor;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        selectedItemColor: activeColor,
        unselectedItemColor: defaultColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range_sharp),
            label: "今天",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: "笔记",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: "卡片",
          ),
        ],
        currentIndex: navigationShell.currentIndex,
        onTap: (int index) => _onTap(context, index),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    ServiceManager.of(context).setCanPopOnce();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
