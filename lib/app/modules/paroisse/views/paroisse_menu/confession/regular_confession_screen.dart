import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/timeline/flutter_timeline.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_confession_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_confession_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RegularConfessionScreen extends StatelessWidget {
  const RegularConfessionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseConfessionController>(builder: (logic) {
      if (logic.isRegularConfessionDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasRegularConfessionData.isTrue) {
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: SmartRefresher(
              controller: logic.refreshController,
              onRefresh: logic.onRegularConfessionsRefresh,
              header: const CustomClassicHeader(),
              child: Accordion(
                disableScrolling: true,
                maxOpenSections: 1,
                scaleWhenAnimating: false,
                leftIcon: SvgPicture.asset(
                  'assets/images/confession_icon.svg',
                  height: 25,
                  colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                ),
                headerBackgroundColor: colorGreenSemiLight,
                contentBorderColor: colorGreenSemiLight,
                children: logic.regularConfessions.map((value) {
                  return AccordionSection(
                    sectionOpeningHapticFeedback:
                    SectionHapticFeedback.medium,
                    sectionClosingHapticFeedback:
                    SectionHapticFeedback.medium,
                    headerPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    isOpen: true,
                    header: Text(
                      '${value.name}',
                      style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.sixteen, textColor: colorWhite),
                    ),
                    content: value.openingTime?.isNotEmpty == true ? TimelineTheme(
                      data: TimelineThemeData(lineColor: colorGrey1),
                      child: Timeline(
                        indicatorSize: 24,
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
                    ) : Text(
                      'Horaires non disponibles pour l\'instant',
                      style: TextStyles
                          .montserratSemiBold(
                          textSize:
                          TextSizes.fourteen,
                          textColor: colorBlack),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return NotFoundScreen(
              message: 'Horaires non disponibles pour l\'instant');
        }
      }
    });
  }
}
