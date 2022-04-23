import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/paroisse_item.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/place_type_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FilterParoisseScreen extends StatelessWidget {
  const FilterParoisseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetBuilder<FilterParoisseController>(
            initState: (state) {},
            builder: (_) {
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
                            top: 16, bottom: 32, left: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _.goBackToParoisse();
                                  },
                                  icon: const Icon(Icons.cancel_rounded,
                                      size: 30),
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
                                        textColor: colorBlack),
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
                                      'Type paroisse',
                                      style: TextStyles.montserratMedium(
                                        textColor: colorGrey1,
                                        textSize: TextSizes.fourteen,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _.paroisseTypes.length,
                                          itemBuilder: (context, index) {
                                            var placeType =
                                                _.paroisseTypes[index];
                                            return PlaceTypeItem(
                                                placeType: placeType);
                                          }),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Diocèse',
                                      style: TextStyles.montserratMedium(
                                        textColor: colorGrey1,
                                        textSize: TextSizes.fourteen,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    MyTextField(
                                      controller: _.dioceseController,
                                      onChanged: (value) {
                                        _.searchCriteria.value.diocese = value;
                                      },
                                    ),
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
                                        _.searchCriteria.value.municipality =
                                            value;
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
                                        _.searchCriteria.value.neighborhood =
                                            value;
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
