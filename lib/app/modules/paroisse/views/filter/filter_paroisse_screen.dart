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
import 'package:oremusapp/app/modules/paroisse/views/widget/diocese_search_widget.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/place_type_item.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/type_liturgical_search_widget.dart';

class FilterParoisseScreen extends StatelessWidget {
  const FilterParoisseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<FilterParoisseController>(builder: (_) {
          return PopScope(
            canPop: false,
            child: KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Column(
                  children: [
                    // En-tête avec fond vert
                    Container(
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 16, left: 16, right: 16),
                      decoration: const BoxDecoration(
                        color: colorGreen,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Boutons de navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bouton retour
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _.doResetFilter();
                                    _.goBackToParoisse();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 20,
                                    color: colorWhite,
                                  ),
                                ),
                              ),

                              // Bouton réinitialiser
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton.icon(
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 20,
                                    color: colorWhite,
                                  ),
                                  label: Text(
                                    'Réinitialiser',
                                    style: TextStyles.montserratMedium(
                                      textColor: colorWhite,
                                      textSize: TextSizes.fourteen,
                                    ),
                                  ),
                                  onPressed: () {
                                    _.doResetFilter();
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Titre
                          Text(
                            'Filtres',
                            style: TextStyles.montserratBold(
                              textColor: colorWhite,
                              textSize: TextSizes.thirty_eight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenu principal
                    Expanded(
                      child: Container(
                        color: colorGrey4,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 16,
                        ),
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (notification) {
                            notification.disallowIndicator();
                            return false;
                          },
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section Type de lieu de culte
                                _buildFilterSection(
                                  title: 'Type de lieu de culte',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Barre de recherche
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: colorWhite,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color:
                                                  colorGreen.withValues(alpha: 0.3)),
                                        ),
                                        child: const Center(
                                          child: TypeLiturgicalSearchWidget(),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Liste des types de lieux
                                      _.isWorshipPlaceDataProcessing.isTrue
                                          ? Center(
                                              child: LoadingView(
                                                size: Get.width / 20,
                                                color: colorGreenSemiLight,
                                              ),
                                            )
                                          : _.hasWorshipPlaceData.isTrue
                                              ? SizedBox(
                                                  height: 50,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount: _
                                                        .paroisseTypesTemp
                                                        .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var placeType =
                                                          _.paroisseTypesTemp[
                                                              index];
                                                      return PlaceTypeItem(
                                                        placeType: placeType,
                                                        key: ValueKey(placeType
                                                            .identifier),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(),
                                    ],
                                  ),
                                ),

                                // Section Diocèse
                                _buildFilterSection(
                                  title: 'Diocèse',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Barre de recherche
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: colorWhite,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color:
                                                  colorGreen.withValues(alpha: 0.3)),
                                        ),
                                        child: const Center(
                                          child: DioceseSearchWidget(),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Liste des diocèses
                                      _.isDioceseDataProcessing.isTrue
                                          ? Center(
                                              child: LoadingView(
                                                size: Get.width / 20,
                                                color: colorGreenSemiLight,
                                              ),
                                            )
                                          : _.hasDioceseData.isTrue
                                              ? SizedBox(
                                                  height: 50,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        _.diocesesTemp.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var diocese =
                                                          _.diocesesTemp[index];
                                                      return DioceseItem(
                                                        diocese: diocese,
                                                        key: ValueKey(diocese
                                                            ?.identifier),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(),
                                    ],
                                  ),
                                ),

                                // Section Ville
                                _buildFilterSection(
                                  title: 'Ville',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: MyTextField(
                                      controller: _.cityController,
                                      onChanged: (value) {
                                        _.searchCriteria.value.city = value;
                                        _.canDoApplyAction();
                                      },
                                      hintText: 'Entrez une ville',
                                    ),
                                  ),
                                ),

                                // Section Commune
                                _buildFilterSection(
                                  title: 'Commune',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: MyTextField(
                                      controller: _.municipalityController,
                                      onChanged: (value) {
                                        _.searchCriteria.value.municipality =
                                            value;
                                        _.canDoApplyAction();
                                      },
                                      hintText: 'Entrez une commune',
                                    ),
                                  ),
                                ),

                                // Section Quartier
                                _buildFilterSection(
                                  title: 'Quartier',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: MyTextField(
                                      controller: _.neighborhoodController,
                                      onChanged: (value) {
                                        _.searchCriteria.value.neighborhood =
                                            value;
                                        _.canDoApplyAction();
                                      },
                                      hintText: 'Entrez un quartier',
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bouton d'application des filtres
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorWhite,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        text: 'Appliquer les filtres',
                        textSize: TextSizes.sixteen,
                        actionColor: colorGreenSemiLight,
                        enabled: _.enabledApplyButton.value,
                        borderColor: _.enabledApplyButton.value
                            ? colorGreen
                            : colorGrey1,
                        bgcolor: _.enabledApplyButton.value
                            ? colorGreen
                            : colorGrey1,
                        action: () {
                          _.goBackToParoisse();
                        },
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: const BoxDecoration(
                  color: colorGreenSemiLight,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyles.montserratSemiBold(
                  textColor: colorGrey1,
                  textSize: TextSizes.fifteen,
                ),
              ),
            ],
          ),
        ),
        child,
        const SizedBox(height: 12),
      ],
    );
  }
}
