import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/customhome/data/model/menu_item.dart';

class DrawerMenuItem extends StatelessWidget {
  DrawerMenuItem({required this.menu, required this.index, Key? key})
      : super(key: key);

  final MenusItem menu;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomHomeController>(
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
                  visible: ((menu.isSelected ?? false) && logic.menus[index].code != AppConstants.SHARE_APP),
                  child: const Icon(
                    Icons.circle,
                    size: 8,
                    color: colorWhite,
                  ),
                ),
                Separators.minimunHorizontal(),
                SvgPicture.asset(
                  menu.icon ?? '',
                  width: 20,
                  colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                  fit: BoxFit.fill,
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
