import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_masse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SpecialMassScreen extends StatelessWidget {
  const SpecialMassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMasseController>(builder: (logic) {
      if (logic.isSpecialMassDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasSpecialMassData.isTrue) {
          return FadeIn(
              duration: const Duration(milliseconds: 500),
              child: SmartRefresher(
                controller: logic.refreshNotRecurrentController,
                onRefresh: logic.onSpecialMassesRefresh,
                header: const CustomClassicHeader(),
                child: GroupedListView<LiturgicalCelebrationResponse?, String>(
                  padding: const EdgeInsets.all(16.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  elements: logic.specialMasses.value,
                  useStickyGroupSeparators: false,
                  groupBy: (liturgicalCelebration) => liturgicalCelebration?.name ?? '',
                  groupHeaderBuilder: (liturgicalCelebration) => Container(
                    padding:
                        const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: colorGreenSemiLight.withOpacity(0.4),
                    ),
                    child: Center(
                      child: Text('${liturgicalCelebration?.name} - ${logic.getDate(liturgicalCelebration?.startDate ?? '')}',
                        style: TextStyles.montserratBold(
                          textSize: TextSizes.seventeen,
                        ),),
                    ),
                  ),
                  order: GroupedListOrder.ASC,
                  itemBuilder: (c, liturgicalCelebration) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            logic.getHour(liturgicalCelebration?.startDate ?? ''),
                            style: TextStyles.montserratMedium(
                              textColor: colorBlack,
                              textSize: TextSizes.thirteen,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ));
        } else {
          return NotFoundScreen(
              message: 'Horaires non disponible pour l\'instant');
        }
      }
    });
  }
}
