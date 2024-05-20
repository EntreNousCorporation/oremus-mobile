import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_confession_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SpecialConfessionScreen extends StatelessWidget {
  const SpecialConfessionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseConfessionController>(builder: (logic) {
      if (logic.isSpecialConfessionDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasSpecialConfessionData.isTrue) {
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: SmartRefresher(
              controller: logic.refreshNotRecurrentController,
              onRefresh: logic.onSpecialConfessionRefresh,
              header: const CustomClassicHeader(),
              child: Accordion(
                disableScrolling: true,
                maxOpenSections: 1,
                scaleWhenAnimating: false,
                leftIcon: SvgPicture.asset(
                  'assets/images/confession_icon.svg',
                  height: 25,
                  colorFilter:
                  const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                ),
                children: logic.specialConfessions.map((value) {
                  return AccordionSection(
                    sectionOpeningHapticFeedback: SectionHapticFeedback.medium,
                    sectionClosingHapticFeedback: SectionHapticFeedback.medium,
                    headerPadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    headerBackgroundColor: isEventExpired(value) ? colorGreyDrawer : colorGreenSemiLight,
                    contentBorderColor: isEventExpired(value) ? colorGreyDrawer : colorGreenSemiLight,
                    isOpen: true,
                    header: Text(
                      '${value.name}',
                      style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.sixteen, textColor: colorWhite),
                    ),
                    content: value.slots?.isNotEmpty == true
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Separators.minimunHorizontal(),
                        Expanded(
                          child: SizedBox(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Jiffy.parse(value.startDate ?? '-').format(pattern: 'dd-MM-yyyy'),
                                  textAlign: TextAlign.start,
                                  style: TextStyles.montserratSemiBold(
                                    textSize: TextSizes.sixteen,
                                    textColor: colorBlack,
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: value.slots?.isNotEmpty ==
                                      true
                                      ? value.slots?.map((timeSlot) {
                                    return Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          right: 8.0),
                                      child: Text(
                                        '${logic.getTime(timeSlot.startTime ?? '')}',
                                        style: TextStyles
                                            .montserratSemiBold(
                                          textSize:
                                          TextSizes.fourteen,
                                          textColor: colorGrey1,
                                        ),
                                      ),
                                    );
                                  }).toList() ??
                                      []
                                      : [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          right: 8.0),
                                      child: Text(
                                        'N/A',
                                        style: TextStyles
                                            .montserratSemiBold(
                                          textSize:
                                          TextSizes.fourteen,
                                          textColor: colorGrey1,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                        : Text(
                      'Horaires non disponibles pour l\'instant',
                      style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.fourteen,
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
