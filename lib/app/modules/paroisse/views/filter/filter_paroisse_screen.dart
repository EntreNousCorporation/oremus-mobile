import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/diocese_item.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/place_type_item.dart';

class FilterParoisseScreen extends StatelessWidget {
  const FilterParoisseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<FilterParoisseController>(builder: (_) {
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
                                _.goBackToParoisse();
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
                          'Filtres',
                          style: TextStyles.montserratBold(
                            textColor: colorBlack,
                            textSize: TextSizes.thirty_eight,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Separators.normalVertical(),
                                Text(
                                  'Type de lieu de culte',
                                  style: TextStyles.montserratMedium(
                                    textColor: colorGrey1,
                                    textSize: TextSizes.fourteen,
                                  ),
                                ),
                                _.isWorshipPlaceDataProcessing.isTrue
                                    ? Center(
                                        child: LoadingView(
                                          size: Get.width / 20,
                                          color: colorGreenSemiLight,
                                        ),
                                      )
                                    : _.hasWorshipPlaceData.isTrue
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Separators.minimunVertical(),
                                              SizedBox(
                                                height: Get.width / 8,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        _.paroisseTypes.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var placeType = _
                                                          .paroisseTypes[index];
                                                      return PlaceTypeItem(
                                                        placeType: placeType,
                                                        key: ValueKey(placeType
                                                            .identifier),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                Separators.normalVertical(),
                                Text(
                                  'Diocèse',
                                  style: TextStyles.montserratMedium(
                                    textColor: colorGrey1,
                                    textSize: TextSizes.fourteen,
                                  ),
                                ),
                                _.isDioceseDataProcessing.isTrue
                                    ? Center(
                                        child: LoadingView(
                                          size: Get.width / 20,
                                          color: colorGreenSemiLight,
                                        ),
                                      )
                                    : _.hasDioceseData.isTrue
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Separators.minimunVertical(),
                                              SizedBox(
                                                height: Get.width / 8,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        _.dioceses.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var diocese =
                                                          _.dioceses[index];
                                                      return DioceseItem(
                                                        diocese: diocese,
                                                        key: ValueKey(
                                                            diocese.identifier),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                Separators.normalVertical(),
                                Text(
                                  'Ville',
                                  style: TextStyles.montserratMedium(
                                    textColor: colorGrey1,
                                    textSize: TextSizes.fourteen,
                                  ),
                                ),
                                Separators.minimunVertical(),
                                MyTextField(
                                  controller: _.cityController,
                                  onChanged: (value) {
                                    _.searchCriteria.value.city = value;
                                    _.canDoApplyAction();
                                  },
                                ),
                                Separators.normalVertical(),
                                Text(
                                  'Commune',
                                  style: TextStyles.montserratMedium(
                                    textColor: colorGrey1,
                                    textSize: TextSizes.fourteen,
                                  ),
                                ),
                                Separators.minimunVertical(),
                                MyTextField(
                                  controller: _.municipalityController,
                                  onChanged: (value) {
                                    _.searchCriteria.value.municipality = value;
                                    _.canDoApplyAction();
                                  },
                                ),
                                Separators.normalVertical(),
                                Text(
                                  'Quartier',
                                  style: TextStyles.montserratMedium(
                                    textColor: colorGrey1,
                                    textSize: TextSizes.fourteen,
                                  ),
                                ),
                                Separators.minimunVertical(),
                                MyTextField(
                                  controller: _.neighborhoodController,
                                  onChanged: (value) {
                                    _.searchCriteria.value.neighborhood = value;
                                    _.canDoApplyAction();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Separators.normalVertical(),
                        CustomButton(
                          text: 'Appliquer les filtres',
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
                            _.goBackToParoisse();
                          },
                        ),
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
