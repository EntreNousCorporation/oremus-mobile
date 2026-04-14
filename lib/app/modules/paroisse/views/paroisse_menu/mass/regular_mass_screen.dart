import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/timeline/flutter_timeline.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_mass_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_masse_item.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class RegularMassScreen extends StatelessWidget {
  const RegularMassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GetX<ParoisseMassController>(builder: (logic) {
        if (logic.isRegularMassDataProcessing.isTrue) {
          return Center(
            child: LottieLoadingView(
              size: Get.width / 4,
            ),
          );
        } else {
          if (logic.hasRegularMassData.isTrue) {
            return FadeIn(
              child: SmartRefresher(
                controller: logic.refreshController,
                onRefresh: logic.onRegularMassesRefresh,
                header: const CustomClassicHeader(),
                child: ListView.builder(
                  itemCount: logic.regularMasses.length,
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    final value = logic.regularMasses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            background: Colors.transparent,
                          ),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          initiallyExpanded: false,
                          collapsedBackgroundColor: Colors.white,
                          backgroundColor: Colors.white,
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'assets/images/messe.svg',
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${value.name}',
                                  style: TextStyles.montserratSemiBold(
                                    textSize: TextSizes.sixteen,
                                    textColor: colorGreenSemiLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: value.openingTime?.isNotEmpty == true
                                  ? TimelineTheme(
                                data: TimelineThemeData(
                                  lineColor: Colors.grey[300]!,
                                  itemGap: 16.0,
                                ),
                                child: Timeline(
                                  indicatorSize: 24,
                                  isLeftAligned: true,
                                  events: value.openingTime?.map((openingTime) {
                                    bool isCurrentDay = getCurrentDay() == getDay(openingTime.dayOfWeek);
                                    return TimelineEventDisplay(
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        child: DayMassItem(openingTime: openingTime),
                                      ),
                                      indicator: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: isCurrentDay ? colorGreenSemiLight : Colors.grey[300]!,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: isCurrentDay
                                              ? [
                                            BoxShadow(
                                              color: colorGreenSemiLight.withValues(alpha: 0.3),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            )
                                          ]
                                              : null,
                                        ),
                                        child: isCurrentDay
                                            ? const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: colorWhite,
                                        )
                                            : null,
                                      ),
                                    );
                                  }).toList() ??
                                      [],
                                ),
                              )
                                  : _buildEmptyMassHours(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return _buildEmptyState('Horaires des messes régulières non disponibles pour l\'instant');
          }
        }
      }),
    );
  }

  // Widget pour afficher un message quand les horaires ne sont pas disponibles
  Widget _buildEmptyMassHours() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Horaires non disponibles pour l\'instant',
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fourteen,
              textColor: Colors.grey[600]!,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // État vide amélioré
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 40,
              color: colorGreen.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyles.montserratBold(
              textSize: TextSizes.eighteen,
              textColor: colorGreenSemiLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}