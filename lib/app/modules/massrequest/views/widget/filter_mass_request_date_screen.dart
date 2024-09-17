import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/worship_recurrent_hours_list.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/worship_special_hours_list.dart';

class FilterMassRequestDateScreen extends StatelessWidget {
  const FilterMassRequestDateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<FilterMassRequestDateController>(builder: (_) {
          return WillPopScope(
            onWillPop: () async => false,
            child: KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Container(
                  color: colorGrey4,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                //_.doResetAndCloseFilter();
                                //_.goBackToMassRequest();
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.cancel_rounded,
                                size: 30,
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(
                                Icons.restore_rounded,
                                size: 30,
                                color: colorBlack,
                              ),
                              label: Text(
                                'Réinitialiser',
                                style: TextStyles.montserratRegular(
                                  textColor: colorBlack,
                                ),
                              ),
                              onPressed: () {
                                _.doResetFilter();
                              },
                            ),
                          ],
                        ),
                        Separators.normalVertical(),
                        Text(
                          'Plusieurs messes',
                          style: TextStyles.montserratBold(
                            textColor: colorBlack,
                            textSize: TextSizes.thirty_eight,
                          ),
                        ),
                        Expanded(
                          child: NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification: (notification) {
                              notification.disallowIndicator();
                              return false;
                            },
                            child: SingleChildScrollView(
                              physics: GetPlatform.isAndroid
                                  ? const BouncingScrollPhysics()
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Separators.normalVertical(),
                                  Visibility(
                                    visible: _.worshipRecurrentHours.isNotEmpty,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          width: double.maxFinite,
                                          color: colorPurpleLight,
                                          child: Text(
                                            'Sélectionner les horaires de vos messes pour répétition',
                                            style: TextStyles.montserratSemiBold(
                                              textColor: colorWhite,
                                              textSize: TextSizes.twenty,
                                            ),
                                          ),
                                        ),
                                        Separators.normalVertical(),
                                        const WorshipRecurrentHoursList(),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: false, //_.worshipSpecialHours.isNotEmpty,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Separators.maximumVertical(),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          width: double.maxFinite,
                                          color: colorPurpleLight,
                                          child: Text(
                                            'Jours spéciaux',
                                            style: TextStyles.montserratSemiBold(
                                              textColor: colorWhite,
                                              textSize: TextSizes.twenty,
                                            ),
                                          ),
                                        ),
                                        Separators.normalVertical(),
                                        const WorshipSpecialHoursList(),
                                      ],
                                    ),
                                  ),
                                  Separators.normalVertical(),

                                  //REPETITION END
                                  Text(
                                    'Date de fin de la répétition',
                                    style: TextStyles.montserratMedium(
                                      textColor: colorGrey1,
                                      textSize: TextSizes.fourteen,
                                    ),
                                  ),
                                  Separators.customSizeVertical(8),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _.selectDate(context, _.initialSelectedDate.value);
                                        },
                                        child: Material(
                                          borderRadius: BorderRadius.circular(10.0),
                                          elevation: 10,
                                          color: colorWhite,
                                          shadowColor: colorGrey2.withOpacity(0.5),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            width: double.maxFinite,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${_.endSelectedDate.value?.dayToDisplay}',
                                                  style: TextStyles.montserratBold(
                                                    textColor: colorBlack,
                                                    textSize: TextSizes.sixteen,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.arrow_drop_down_rounded,
                                                  size: 25,
                                                  color: colorGreen,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Separators.maximumVertical(),
                                    ],
                                  ),
                                  Separators.normalVertical(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Separators.normalVertical(),
                        CustomButton(
                          text: 'Continuer',
                          textSize: TextSizes.eighteen,
                          actionColor: colorGreenSemiLight,
                          enabled: _.enabledApplyButton.value == false
                              ? false
                              : true,
                          borderColor: _.enabledApplyButton.value == false
                              ? colorGrey1
                              : colorGreen,
                          bgcolor: _.enabledApplyButton.value == false
                              ? colorGrey1
                              : colorGreen,
                          action: () {
                            _.moveToRecap();
                          },
                        ),
                        Separators.normalVertical(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
