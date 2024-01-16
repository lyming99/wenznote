import 'package:flutter/material.dart';

Widget buildMenuGroup(BuildContext context, Iterable<Widget> widgets) {
  return Container(
    margin: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    clipBehavior: Clip.antiAlias,
    child: Material(
      child: Column(
        children: [
          ...widgets,
        ],
      ),
    ),
  );
}