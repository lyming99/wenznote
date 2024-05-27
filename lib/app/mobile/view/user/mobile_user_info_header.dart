import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:wenznote/app/mobile/controller/user/mobile_user_header_controller.dart';
import 'package:wenznote/app/mobile/theme/mobile_theme.dart';
import 'package:wenznote/commons/mvc/view.dart';

import 'mobile_user_icon.dart';

class MobileUserHeaderWidget extends MvcView<MobileUserHeaderController> {
  const MobileUserHeaderWidget({super.key, required super.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MobileTheme.of(context).mobileNavBgColor,
      child: SafeArea(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.hasLogin
                  ? () {
                      controller.openUserInfoPage();
                    }
                  : () {
                      controller.openLoginPage();
                    },
              child: buildContent(context),
            )),
      ),
    );
  }

  Column buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 头像、昵称(会员标志)、签名
        Row(
          children: [
            // 头像
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              clipBehavior: Clip.antiAlias,
              child: MobileUserIcon(),
            ),
            // 昵称以及签名
            Expanded(
              child: controller.hasLogin
                  ? buildInfo(context)
                  : buildLoginButton(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 昵称以及会员标志
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 140),
              child: Text(
                "${controller.userName}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 4,
            ),

          ],
        ),
        SizedBox(
          height: 4,
        ),
        // 签名
        Text(
          "${controller.userNote}",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return Row(
      children: [
        fluent.HyperlinkButton(
          style: fluent.ButtonStyle(
            padding: fluent.ButtonState.all(
              const EdgeInsets.symmetric(horizontal: 2),
            ),
          ),
          child: const Text("未登录"),
          onPressed: () {
            controller.openLoginPage();
          },
        ),
      ],
    );
  }
}
