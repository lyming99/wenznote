library loader_skeleton;

import 'package:flutter/material.dart';

Decoration myBoxDec(animation, {isCircle = false}) {
  return BoxDecoration(
    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xff9b9b9b),
        Color(0xffc0c0c0),
        Color(0xff757575),
      ],
      stops: [
        // animation.value * 0.1,
        animation.value - 1,
        animation.value,
        animation.value + 1,
        // animation.value + 5,
        // 1.0,
      ],
    ),
  );
}

class CardSkeleton extends StatefulWidget {
  final bool isCircularImage;
  final bool isBottomLinesActive;
  CardSkeleton({this.isCircularImage = true, this.isBottomLinesActive = true});
  @override
  _CardSkeletonState createState() => _CardSkeletonState();
}

class _CardSkeletonState extends State<CardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    animation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(curve: Curves.easeInOutSine, parent: _controller));

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: width * 0.13,
                      width: width * 0.13,
                      decoration:
                      myBoxDec(animation, isCircle: widget.isCircularImage),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: width * 0.13,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: height * 0.008,
                            width: width * 0.3,
                            decoration: myBoxDec(animation),
                          ),
                          Container(
                            height: height * 0.007,
                            width: width * 0.2,
                            decoration: myBoxDec(animation),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                widget.isBottomLinesActive
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 16,
                      width: width * 0.7,
                      decoration: myBoxDec(animation),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 16,
                      width: width * 0.8,
                      decoration: myBoxDec(animation),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 16,
                      width: width * 0.5,
                      decoration: myBoxDec(animation),
                    ),
                  ],
                )
                    : Offstage()
              ],
            ),
          ),
        );
      },
    );
  }
}

Decoration myDarkBoxDec(animation, {isCircle = false}) {
  return BoxDecoration(
    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.grey[700]!,
        Colors.grey[600]!,
        Colors.grey[700]!,
        // Color(0xfff6f7f9),
      ],
      stops: [
        // animation.value * 0.1,
        animation.value - 1,
        animation.value,
        animation.value + 1,
        // animation.value + 5,
        // 1.0,
      ],
    ),
  );
}

class CardPageSkeleton extends StatefulWidget {
  final int totalLines;
  CardPageSkeleton({this.totalLines = 5});
  @override
  _CardPageSkeletonState createState() => _CardPageSkeletonState();
}

class _CardPageSkeletonState extends State<CardPageSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1,),
    );

    animation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(curve: Curves.easeInOutSine, parent: _controller));

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _controller.repeat();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20,left: 10),
      child: LayoutBuilder(
        builder: (context,cons) {
          var width = cons.maxWidth;
          var height = MediaQuery.of(context).size.height;
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return SizedBox(
                  width: cons.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        widget.totalLines,
                            (i) => Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 10,
                              width: width * 0.7,
                              decoration: myBoxDec(animation),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 10,
                              width: width * 0.9,
                              decoration: myBoxDec(animation),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 10,
                              width: width * 0.6,
                              decoration: myBoxDec(animation),
                            ),
                          ],
                        )).toList(),
                  ));
            },
          );
        }
      ),
    );
  }
}

