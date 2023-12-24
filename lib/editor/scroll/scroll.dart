import 'package:flutter/material.dart';
import 'package:note/editor/edit_controller.dart';

class ScrollState {
  double _offset = 0;

  ScrollState();

  double get offset {
    return _offset;
  }

  set offset(val) {
    _offset = val;
  }
}
class MouseDragScrollTimer{
  double speed=0;

}