import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_masse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_masse_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RegularMassScreen extends StatelessWidget {
  const RegularMassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMasseController>(builder: (logic) {
      if (logic.isRegularMassDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasRegularMassData.isTrue) {
          return FadeIn(
            duration:
            const Duration(milliseconds: 500),
            child: SmartRefresher(
              controller: logic.refreshController,
              onRefresh: logic.onRegularMassesRefresh,
              child: Accordion(
                disableScrolling: true,
                maxOpenSections: 1,
                leftIcon: SvgPicture.asset(
                  'assets/images/messe.svg',
                  height: 25,
                  color: colorWhite,
                ),
                headerBackgroundColor:
                colorGreenSemiLight,
                contentBorderColor:
                colorGreenSemiLight,
                children: logic.regularMasses.value.map((value) {
                  return AccordionSection(
                    isOpen: true,
                    header: Text(
                      '${value.name}',
                      style: TextStyles
                          .montserratSemiBold(
                          textSize:
                          TextSizes.sixteen,
                          textColor: colorWhite),
                    ),
                    content: ListView.builder(
                        padding:
                        const EdgeInsets.all(0),
                        physics:
                        const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                        value.openingTime?.length,
                        itemBuilder: (context, i) {
                          var openingTime =
                          value.openingTime?[i];
                          return DayMassetem(
                              openingTime:
                              openingTime);
                        }),
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return NotFoundScreen(
              message: 'Horaires non disponible pour l\'instant');
        }
      }
    });
  }
}
