import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/mass_request_type_search_widget.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/type_data_item.dart';

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
                                _.doResetFilter();
                                _.goBackToMassRequestHistory();
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
                          'Choix de dates',
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
                                  : const ClampingScrollPhysics(),
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
                                          color: colorGreen,
                                          child: Text(
                                            'Jours récurrents',
                                            style: TextStyles.montserratSemiBold(
                                              textColor: colorWhite,
                                              textSize: TextSizes.twenty,
                                            ),
                                          ),
                                        ),
                                        Separators.minimunVertical(),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              _.worshipRecurrentHours.length,
                                          itemBuilder: (context, index) {
                                            var item = _.worshipRecurrentHours[index];
                                            return Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  getDay(int.parse(item.dayOfWeek ?? '')),
                                                  style: TextStyles
                                                      .montserratSemiBold(
                                                    textColor: colorGrey1,
                                                    textSize:
                                                    TextSizes.fourteen,
                                                  ),
                                                ),
                                                Separators.normalVertical(),
                                                Wrap(
                                                  alignment:
                                                  WrapAlignment.start,
                                                  direction: Axis.horizontal,
                                                  children: item.slots
                                                      ?.map(
                                                        (e) => Container(
                                                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      decoration:
                                                      BoxDecoration(
                                                        /*color: logic.massRequestTypeSelected.value == typeData
                                                                    ? colorGreenSemiLight
                                                                    : colorWhite,*/
                                                        color:
                                                        colorWhite,
                                                        border: Border.all(
                                                            color:
                                                            colorGreenSemiLight),
                                                        borderRadius:
                                                        BorderRadius.circular(Get.width /
                                                            10),
                                                      ),
                                                      child:
                                                      Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child:
                                                        Text(
                                                          '${e.startTime}',
                                                          textAlign:
                                                          TextAlign.center,
                                                          style:
                                                          TextStyles.montserratSemiBold(
                                                            textSize:
                                                            TextSizes.fourteen,
                                                            textColor:
                                                            colorBlack,
                                                            /*textColor: logic.massRequestTypeSelected.value == typeData
                                                                        ? colorWhite
                                                                        : colorBlack,*/
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ).toList() ?? [],
                                                ),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return Separators.normalVertical();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _.worshipSpecialHours.isNotEmpty,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Separators.maximumVertical(),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          width: double.maxFinite,
                                          color: colorGreen,
                                          child: Text(
                                            'Jours spéciaux',
                                            style: TextStyles.montserratSemiBold(
                                              textColor: colorWhite,
                                              textSize: TextSizes.twenty,
                                            ),
                                          ),
                                        ),
                                        Separators.minimunVertical(),
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              _.worshipSpecialHours.length,
                                          itemBuilder: (context, index) {
                                            var item =
                                                _.worshipSpecialHours[index];
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${item.day}',
                                                  style: TextStyles
                                                      .montserratSemiBold(
                                                    textColor: colorGrey1,
                                                    textSize:
                                                        TextSizes.fourteen,
                                                  ),
                                                ),
                                                Separators.normalVertical(),
                                                Wrap(
                                                  alignment:
                                                      WrapAlignment.start,
                                                  direction: Axis.horizontal,
                                                  children: item.slots
                                                          ?.map(
                                                            (e) => Container(
                                                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                /*color: logic.massRequestTypeSelected.value == typeData
                                                                    ? colorGreenSemiLight
                                                                    : colorWhite,*/
                                                                color:
                                                                    colorWhite,
                                                                border: Border.all(
                                                                    color:
                                                                        colorGreenSemiLight),
                                                                borderRadius:
                                                                    BorderRadius.circular(Get.width /
                                                                        10),
                                                              ),
                                                              child:
                                                                  Padding(
                                                                padding: const EdgeInsets.all(10.0),
                                                                child:
                                                                    Text(
                                                                  '${e.startTime}',
                                                                  textAlign:
                                                                      TextAlign.center,
                                                                  style:
                                                                      TextStyles.montserratSemiBold(
                                                                    textSize:
                                                                        TextSizes.fourteen,
                                                                    textColor:
                                                                        colorBlack,
                                                                    /*textColor: logic.massRequestTypeSelected.value == typeData
                                                                        ? colorWhite
                                                                        : colorBlack,*/
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
                                        ),
                                      ],
                                    ),
                                  ),
                                  Separators.normalVertical(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Separators.normalVertical(),
                        CustomButton(
                          text: 'Valider',
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
                            _.goBackToMassRequestHistory();
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
