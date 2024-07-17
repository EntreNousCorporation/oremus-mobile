import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

class WorshipSpecialHoursList extends StatelessWidget {
  const WorshipSpecialHoursList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestDateController>(
      builder: (_) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _.worshipSpecialHours.length,
          itemBuilder: (context, index) {
            var item = _.worshipSpecialHours[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getCustomDate(item.day,
                      pattern: AppConstants.TIME_SIMPLE_FORMAT2),
                  style: TextStyles.montserratSemiBold(
                    textColor: colorPurpleLight,
                    textSize: TextSizes.sixteen,
                  ),
                ),
                Separators.normalVertical(),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: item.slots
                          ?.map(
                            (e) => GestureDetector(
                              onTap: () {
                                e.isHourSelected = !e.isHourSelected!;
                                _.onWorshipSpecialHoursSelected(item);
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: e.isHourSelected == true
                                      ? colorGreenSemiLight
                                      : colorWhite,
                                  border:
                                      Border.all(color: colorGreenSemiLight),
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
