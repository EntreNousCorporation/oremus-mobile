import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                Row(
                  children: [
                    Text(
                      getDay(int.parse(item.dayOfWeek ?? '')),
                      style: TextStyles.montserratSemiBold(
                        textColor: colorPurpleLight,
                        textSize: TextSizes.twenty,
                      ),
                    ),
                    Separators.minimunHorizontal(),
                    Visibility(
                      visible: true,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              //_.selectDate(context, item);
                              _.showCustomDatePicker(context, item);
                            },
                            child: const Icon(
                              Icons.edit_calendar_rounded,
                              color: colorPurpleLight,
                              size: 25,
                            ),
                          ),
                          Visibility(
                            visible: item.isDaySelected == true,
                            child: Row(
                              children: [
                                Separators.minimunHorizontal(),
                                GestureDetector(
                                  onTap: () {
                                    _.onWorshipRecurrentHoursRemoved(item);
                                  },
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: colorRed1,
                                    size: 25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: item.day?.isNotEmpty == true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Separators.minimunVertical(),
                      Text(
                        item.dayToDisplay ?? '-',
                        style: TextStyles.montserratSemiBold(
                          textColor: colorGreenSemiLight,
                          textSize: TextSizes.sixteen,
                        ),
                      ),
                    ],
                  ),
                ),
                Separators.normalVertical(),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: item.slots
                          ?.map(
                            (e) => GestureDetector(
                              onTap: item.isDaySelected == true
                                  ? () {
                                      e.isHourSelected = !e.isHourSelected!;
                                      _.onWorshipRecurrentHoursSelected(
                                          item, false);
                                    }
                                  : () {
                                      showNotification(
                                        message:
                                            'Veuillez d\'abord choisir une date pour le ${getDay(int.parse(item.dayOfWeek ?? ''))}',
                                        bgColor: colorBlue2,
                                      );
                                    },
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: e.isHourSelected == true
                                          ? colorGreenSemiLight
                                          : colorWhite,
                                      border: Border.all(
                                          color: item.isDaySelected == true
                                              ? colorGreenSemiLight
                                              : colorGrey1),
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
                                              : item.isDaySelected == true
                                                  ? colorBlack
                                                  : colorGrey1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  e.isHourSelected == true
                                      ? Positioned(
                                          top: -8,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              border: Border.all(color: colorGreenSemiLight),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Icon(Icons.check, color: colorGreenSemiLight, size: 15,),
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
