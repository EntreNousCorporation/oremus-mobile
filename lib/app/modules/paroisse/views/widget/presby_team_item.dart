import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_presby_team_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';

class PresbyTeamItem extends StatelessWidget {
  PresbyTeamItem({Key? key, required this.user}) : super(key: key);

  PlaceUser user;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoissePresbyTeamController>(builder: (logic) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 10,
          shadowColor: colorGrey2.withValues(alpha: 0.5),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/priest_icon.svg',
                  height: 30,
                  color: colorGreenSemiLight,
                ),
                Separators.normalHorizontal(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${logic.getPresbyType(user.type ?? '')}',
                        style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.sixteen,
                          textColor: colorGreenSemiLight,
                        ),
                      ),
                      Text(
                        '${user.firstname} ${user.lastname}',
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen,
                          textColor: colorBlack.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Separators.normalHorizontal(),
                Visibility(
                  visible: false,
                  child: Container(
                    height: 10,
                    width: 1,
                    color: colorGreenSemiLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
