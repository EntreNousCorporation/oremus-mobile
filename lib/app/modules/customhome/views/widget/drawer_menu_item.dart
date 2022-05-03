import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';

class DrawerMenuItem extends StatelessWidget {
  DrawerMenuItem({required this.menu, required this.index, Key? key})
      : super(key: key);

  MenuItem menu;
  int index;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomHomeController>(
      initState: (_) {},
      builder: (logic) {
        return TextButton(
          onPressed: () {
            logic.doRedirection(index, logic.drawerController);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: menu.isSelected ?? false,
                  child: const Icon(
                    Icons.circle,
                    size: 8,
                    color: colorWhite,
                  ),
                ),
                Separators.minimunHorizontal(),
                SvgPicture.asset(
                  menu.icon ?? '',
                  height: 20,
                  color: colorWhite,
                ),
                Separators.normalHorizontal(),
                Text(
                  menu.libelle ?? '',
                  maxLines: 2,
                  style: TextStyles.montserratRegular(
                      textSize: TextSizes.fourteen, textColor: colorWhite),
                ),
                //Expanded(child: Container()),
                const Visibility(
                  visible: false,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorWhite,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
