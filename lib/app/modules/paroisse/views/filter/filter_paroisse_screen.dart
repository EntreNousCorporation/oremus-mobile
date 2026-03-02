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
    final controller = Get.find<FilterParoisseController>();

    return Container(
      color: colorGreen,
      child: GetBuilder<FilterParoisseController>(
        builder: (controller) {
          return PopScope(
            canPop: false,
            child: KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: colorGreen,
                body: Column(
                  children: [
                    // En-tête avec fond vert - Design amélioré
                    SizedBox(height: MediaQuery.of(context).padding.top),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 12, bottom: 20, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: colorGreen,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Boutons de navigation avec design amélioré
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Bouton retour avec animation
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 400),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          controller.doResetFilter();
                                          controller.goBackToParoisse();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          size: 20,
                                          color: colorWhite,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Bouton réinitialiser avec animation
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 600),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
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
                                          controller.doResetFilter();
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Titre avec animation
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: Text(
                                    'Filtres',
                                    style: TextStyles.montserratBold(
                                      textColor: colorWhite,
                                      textSize: TextSizes.thirty_eight,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Sous-titre explicatif
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 900),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Affinez votre recherche de paroisse',
                                    style: TextStyles.montserratRegular(
                                      textColor: Colors.white.withValues(alpha: 0.8),
                                      textSize: TextSizes.sixteen,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Contenu principal - Design amélioré
                    Expanded(
                      child: Container(
                        color: colorGrey4,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
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
                                // Section Type de lieu de culte - Design amélioré
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: _buildFilterSection(
                                          title: 'Type de lieu de culte',
                                          icon: Icons.church_rounded,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Barre de recherche améliorée
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: colorWhite,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                      color: colorGreen.withValues(alpha: 0.3)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.03),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: TypeLiturgicalSearchWidget(),
                                                ),
                                              ),

                                              const SizedBox(height: 16),

                                              // Liste des types de lieux avec Obx pour réactivité
                                              Obx(() => controller.isWorshipPlaceDataProcessing.isTrue
                                                  ? Center(
                                                child: LoadingView(
                                                  size: Get.width / 20,
                                                  color: colorGreenSemiLight,
                                                ),
                                              )
                                                  : controller.hasWorshipPlaceData.isTrue
                                                  ? Container(
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: controller.paroisseTypesTemp.length,
                                                  itemBuilder: (context, index) {
                                                    var placeType = controller.paroisseTypesTemp[index];
                                                    return PlaceTypeItem(
                                                      placeType: placeType,
                                                      key: ValueKey(placeType.identifier),
                                                    );
                                                  },
                                                ),
                                              )
                                                  : const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                                  child: Text(
                                                    'Aucun type disponible',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Section Diocèse - Design amélioré
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 600),
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: _buildFilterSection(
                                          title: 'Diocèse',
                                          icon: Icons.account_balance,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Barre de recherche améliorée
                                              Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: colorWhite,
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                      color: colorGreen.withValues(alpha: 0.3)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.03),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: DioceseSearchWidget(),
                                                ),
                                              ),

                                              const SizedBox(height: 16),

                                              // Liste des diocèses avec Obx pour réactivité
                                              Obx(() => controller.isDioceseDataProcessing.isTrue
                                                  ? Center(
                                                child: LoadingView(
                                                  size: Get.width / 20,
                                                  color: colorGreenSemiLight,
                                                ),
                                              )
                                                  : controller.hasDioceseData.isTrue
                                                  ? Container(
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: controller.diocesesTemp.length,
                                                  itemBuilder: (context, index) {
                                                    var diocese = controller.diocesesTemp[index];
                                                    return DioceseItem(
                                                      diocese: diocese,
                                                      key: ValueKey(diocese?.identifier),
                                                    );
                                                  },
                                                ),
                                              )
                                                  : const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                                  child: Text(
                                                    'Aucun diocèse disponible',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Section Ville - Design amélioré
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 700),
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: _buildFilterSection(
                                          title: 'Ville',
                                          icon: Icons.location_city,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: MyTextField(
                                              controller: controller.cityController,
                                              onChanged: (value) {
                                                controller.searchCriteria.value.city = value;
                                                controller.canDoApplyAction();
                                              },
                                              hintText: 'Entrez une ville',
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Section Commune - Design amélioré
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 800),
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: _buildFilterSection(
                                          title: 'Commune',
                                          icon: Icons.apartment,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: MyTextField(
                                              controller: controller.municipalityController,
                                              onChanged: (value) {
                                                controller.searchCriteria.value.municipality = value;
                                                controller.canDoApplyAction();
                                              },
                                              hintText: 'Entrez une commune',
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Section Quartier - Design amélioré
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 900),
                                  builder: (context, double value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: _buildFilterSection(
                                          title: 'Quartier',
                                          icon: Icons.holiday_village,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: MyTextField(
                                              controller: controller.neighborhoodController,
                                              onChanged: (value) {
                                                controller.searchCriteria.value.neighborhood = value;
                                                controller.canDoApplyAction();
                                              },
                                              hintText: 'Entrez un quartier',
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bouton d'application des filtres - Design amélioré avec Obx pour réactivité
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorWhite,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 15,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: 0.8 + (value * 0.2),
                            child: Obx(() => CustomButton(
                              text: 'Appliquer les filtres',
                              textSize: TextSizes.sixteen,
                              actionColor: colorGreenSemiLight,
                              enabled: controller.enabledApplyButton.value,
                              borderColor:
                              controller.enabledApplyButton.value ? colorGreen : colorGrey1,
                              bgcolor: controller.enabledApplyButton.value ? colorGreen : colorGrey1,
                              action: () {
                                controller.goBackToParoisse();
                              },
                              borderRadius: 16,
                            )),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
    required IconData icon
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colorGreenSemiLight,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyles.montserratSemiBold(
                  textColor: colorGreenSemiLight,
                  textSize: TextSizes.sixteen,
                ),
              ),
            ],
          ),
        ),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}