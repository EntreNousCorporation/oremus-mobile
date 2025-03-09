import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/map/paroisse_map_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/map_type_choice.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/map_view_google.dart';

class ParoisseMapScreen extends StatelessWidget {
  const ParoisseMapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          // Vue de la carte Google Maps
          const MapViewGoogle(),

          // Fenêtre d'information personnalisée
          GetBuilder<ParoisseMapController>(builder: (logic) {
            return CustomInfoWindow(
              controller: logic.mapController,
              width: Get.width/1.2,
              height: Get.width/2.2, // Légèrement réduit pour un meilleur aspect
              offset: 50,
            );
          }),

          // Panel de navigation supérieur
          Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton retour
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: (Get.width / 9),
                    width: (Get.width / 9),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: colorGreenSemiLight,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Contrôle du type de carte (à droite pour meilleur équilibre)
                Container(
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const MapTypeChoice(),
                ),
              ],
            ),
          ),

          // Titre de l'écran
          GetBuilder<ParoisseMapController>(
            builder: (logic) {
              return Positioned(
                top: kToolbarHeight + (Get.width / 9) + 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorGreenSemiLight.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 20,
                          color: colorGreenSemiLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Emplacement',
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.fourteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              logic.paroisseSelected.value.name ?? 'Paroisse',
                              style: TextStyles.montserratRegular(
                                textSize: TextSizes.thirteen,
                                textColor: Colors.grey[700]!,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Bouton pour recentrer sur la paroisse
          GetBuilder<ParoisseMapController>(
            builder: (logic) {
              return Positioned(
                bottom: 20,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    // Recentrer la carte sur la position de la paroisse
                    logic.centerOnParoisse();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorGreenSemiLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.center_focus_strong_rounded,
                        color: colorWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
