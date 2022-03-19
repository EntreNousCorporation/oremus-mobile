import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';

class AppNavigationBar extends StatelessWidget {
  AppNavigationBar({this.title = '', this.showBackButton = true, Key? key}) : super(key: key);

  var title;
  var showBackButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (showBackButton) Get.back();
              },
              child: Row(
                children: [
                  Visibility(
                    visible: showBackButton,
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: colorBlack,
                        fontSize: 22,
                        fontFamily: 'montserrat_bold'),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: false,
              child: SvgPicture.asset('assets/images/icon_menu.svg'),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        const Visibility(
          visible: false,
          child: Divider(
            height: 1,
            color: colorGreySeparator,
          ),
        ),
      ],
    );
  }
}
