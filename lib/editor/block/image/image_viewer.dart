import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:wenznote/app/windows/theme/colors.dart';
import 'package:wenznote/commons/widget/ignore_parent_pointer.dart';
import 'package:wenznote/editor/widget/drop_menu.dart';
import 'package:wenznote/editor/widget/toggle_item.dart';
import 'package:window_manager/window_manager.dart';

Future<void> showImageViewer(
    BuildContext context, List<ImageProvider> images) async {
  await showPopupWindow(
      context,
      ImageViewer(
        images: images,
      ));
}

class ImageViewer extends StatefulWidget {
  final List<ImageProvider> images;

  const ImageViewer({
    Key? key,
    required this.images,
  }) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        padding: const EdgeInsets.all(60),
        color: systemColor(context,"dialogBackgroundColor"),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                  blurRadius: 10,
                  // blurStyle: BlurStyle.outer,
                  color: systemColor(context,"shadowBoxColor")),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              EasyImageViewPager(
                  easyImageProvider: SingleImageProvider(widget.images.first),
                  pageController: pageController,
                  doubleTapZoomable: false,
                  onScaleChanged: (scale) {}),
              Align(
                alignment: Alignment.topRight,
                child: IgnoreParentPointer(
                  child: ToggleItem(
                    onTap: (ctx) {
                      closePopupWindow(ctx);
                    },
                    itemBuilder: (BuildContext context, bool checked,
                        bool hover, bool pressed) {
                      return Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.close,
                          color: hover
                              ? systemColor(context,"closeImageButtonColor")
                              : systemColor(context,"closeImageButtonColor")
                                  .withOpacity(0.4),
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {});
  }
}
