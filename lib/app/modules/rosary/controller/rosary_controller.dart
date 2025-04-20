import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/rosary_painter_variant.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class RosaryController extends GetxController {

  RosaryController();

  var unlockBackButton = true.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  // Thème actuel (observable)
  final Rx<RosaryStyle> currentStyle = RosaryStyle.classic.obs;
  final Rx<RosaryColorTheme> currentColorTheme = RosaryColorTheme.original.obs;

  // Map de noms lisibles pour l'interface utilisateur
  final Map<RosaryStyle, String> styleNames = {
    RosaryStyle.classic: 'Classique',
    RosaryStyle.elegant: 'Élégant',
    RosaryStyle.minimalist: 'Minimaliste',
    RosaryStyle.luxurious: 'Luxueux',
  };

  final Map<RosaryColorTheme, String> themeNames = {
    RosaryColorTheme.original: 'Original (Vert)',
    RosaryColorTheme.monochrome: 'Monochrome',
    RosaryColorTheme.aurora: 'Aurore Boréale',
    RosaryColorTheme.serenity: 'Sérénité',
    RosaryColorTheme.amber: 'Ambré',
    RosaryColorTheme.vegetal: 'Végétal',
  };

  // Variable pour forcer la mise à jour du dialog
  final RxInt dialogUpdateTrigger = 0.obs;

  // Méthodes pour changer le style et le thème
  void changeStyle(RosaryStyle style) {
    currentStyle.value = style;
    // Incrémente la valeur pour forcer la mise à jour
    dialogUpdateTrigger.value++;
    update(); // Forcer la mise à jour de l'UI
  }

  void changeColorTheme(RosaryColorTheme theme) {
    currentColorTheme.value = theme;
    // Incrémente la valeur pour forcer la mise à jour
    dialogUpdateTrigger.value++;
    update(); // Forcer la mise à jour de l'UI
  }

  // Obtenir le texte du style actuel pour l'affichage
  String get currentStyleText => styleNames[currentStyle.value] ?? 'Classique';

  // Obtenir le texte du thème de couleur actuel pour l'affichage
  String get currentColorThemeText => themeNames[currentColorTheme.value] ?? 'Original';

  // Settings dialog
  void showSettingsDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Obx(() {
          // Cette ligne force le widget à se reconstruire lorsque dialogUpdateTrigger change
          dialogUpdateTrigger.value;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Paramètres',
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.eighteen,
                      textColor: colorGreenSemiLight,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sélecteur de style
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Style:',
                          style: TextStyles.montserratSemiBold(
                            textSize: TextSizes.sixteen,
                            textColor: Colors.black87,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButton<RosaryStyle>(
                            value: currentStyle.value,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: colorGreenSemiLight),
                            items: RosaryStyle.values.map((style) {
                              return DropdownMenuItem<RosaryStyle>(
                                value: style,
                                child: Text(
                                  styleNames[style] ?? '',
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.fourteen,
                                    textColor: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newStyle) {
                              if (newStyle != null) {
                                changeStyle(newStyle);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sélecteur de thème de couleur
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Couleurs:',
                          style: TextStyles.montserratSemiBold(
                            textSize: TextSizes.sixteen,
                            textColor: Colors.black87,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButton<RosaryColorTheme>(
                            value: currentColorTheme.value,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: colorGreenSemiLight),
                            items: RosaryColorTheme.values.map((theme) {
                              return DropdownMenuItem<RosaryColorTheme>(
                                value: theme,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Indicateur de couleur
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getThemePreviewColor(theme),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.black12, width: 1),
                                      ),
                                      margin: const EdgeInsets.only(right: 8),
                                    ),
                                    // Nom du thème
                                    Text(
                                      themeNames[theme] ?? '',
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newTheme) {
                              if (newTheme != null) {
                                changeColorTheme(newTheme);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorGreenSemiLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      'Fermer',
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.fourteen,
                        textColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Color _getThemePreviewColor(RosaryColorTheme theme) {
    return RosaryTheme.getTheme(theme).activeColor;
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
