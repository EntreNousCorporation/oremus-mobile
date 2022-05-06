import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_timeline/flutter_timeline.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_confession_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_confession_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RegularConfessionScreen extends StatelessWidget {
  const RegularConfessionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseConfessionController>(builder: (logic) {
      if (logic.isRegularMassDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasRegularMassData.isTrue) {
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: SmartRefresher(
              controller: logic.refreshController,
              onRefresh: logic.onRegularConfessionsRefresh,
              child: Accordion(
                disableScrolling: true,
                maxOpenSections: 1,
                leftIcon: SvgPicture.asset(
                  'assets/images/confession_icon.svg',
                  height: 25,
                  color: colorWhite,
                ),
                headerBackgroundColor: colorGreenSemiLight,
                contentBorderColor: colorGreenSemiLight,
                children: logic.regularConfessions.value.map((value) {
                  return AccordionSection(
                    isOpen: true,
                    header: Text(
                      '${value.name}',
                      style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.sixteen, textColor: colorWhite),
                    ),
                    content: TimelineTheme(
                      data: TimelineThemeData(lineColor: colorGrey1),
                      child: Timeline(
                        indicatorSize: 18,
                        events: value.openingTime!.map((openingTime) {
                          return TimelineEventDisplay(
                            child: DayConfessionItem(openingTime: openingTime),
                            indicator: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: getCurrentDay() ==
                                    getDay(openingTime.dayOfWeek)
                                    ? colorGreenSemiLight
                                    : colorGrey1,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: getCurrentDay() ==
                                  getDay(openingTime.dayOfWeek)
                                  ? const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: colorWhite,
                              )
                                  : const Icon(
                                Icons.circle,
                                size: 18,
                                color: colorWhite,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
