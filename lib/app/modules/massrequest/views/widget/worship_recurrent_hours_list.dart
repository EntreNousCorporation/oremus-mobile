import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

class WorshipRecurrentHoursList extends StatelessWidget {
  const WorshipRecurrentHoursList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestDateController>(
      builder: (_) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _.worshipRecurrentHours.length,
          itemBuilder: (context, index) {
            var item = _.worshipRecurrentHours[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getDay(int.parse(item.dayOfWeek ?? '')),
                  style: TextStyles.montserratSemiBold(
                    textColor: colorPurpleLight,
                    textSize: TextSizes.twenty,
                  ),
                ),
                Separators.normalVertical(),
                Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 15,
                  spacing: 0,
                  direction: Axis.horizontal,
                  children: item.slots
                          ?.map(
                            (e) => GestureDetector(
                              onTap: !isDayOfWeekInDateRange(int.parse(item.dayOfWeek ?? '0'), Jiffy.parse(_.initialSelectedDate.value?.day ?? '').dateTime, Jiffy.parse(_.endSelectedDate.value?.day ?? '').dateTime)
                                  ? () {
                                      showNotification(
                                        message: 'Vous ne pouvez pas sélectionner cet horaire après la date de fin de répétition',
                                        bgColor: colorBlue2,
                                      );
                                    }
                                  : () {
                                      e.isHourSelected = !e.isHourSelected!;
                                      _.onWorshipRecurrentHoursSelected(
                                          item, true);
                                    },
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: e.isHourSelected == true
                                          ? colorGreenSemiLight
                                          : colorWhite,
                                      border: Border.all(
                                          color: colorGreenSemiLight),
                                      borderRadius:
                                          BorderRadius.circular(Get.width / 10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        '${e.startTime}',
                                        textAlign: TextAlign.center,
                                        style: TextStyles.montserratSemiBold(
                                          textSize: TextSizes.fourteen,
                                          textColor: e.isHourSelected == true
                                              ? colorWhite
                                              : colorBlack,
                                        ),
                                      ),
                                    ),
                                  ),
                                  e.isHourSelected == true
                                      ? Positioned(
                                          top: -8,
                                    right: 3,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              border: Border.all(
                                                  color: colorGreenSemiLight),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: colorGreenSemiLight,
                                              size: 15,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
                          )
                          .toList() ??
                      [],
                ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return Separators.normalVertical();
          },
        );
      },
    );
  }
}
