import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:animations/animations.dart';
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

  static const String KEY_ROSARY_STYLE = 'rosary_style';
  static const String KEY_ROSARY_COLOR_THEME = 'rosary_color_theme';

  // Thème actuel (observable)
  final Rx<RosaryStyle> currentStyle = RosaryStyle.classic.obs;
  final Rx<RosaryColorTheme> currentColorTheme = RosaryColorTheme.original.obs;

  // Map de noms lisibles pour l'interface utilisateur
  final Map<RosaryStyle, String> styleNames = {
    RosaryStyle.classic: 'Classique',
    RosaryStyle.elegant: 'Élégant',
    RosaryStyle.minimalist: 'Minimaliste',
    RosaryStyle.luxurious: 'Luxueux',
    RosaryStyle.modern: 'Moderne',
  };

  final Map<RosaryColorTheme, String> themeNames = {
    RosaryColorTheme.original: 'Original (Par défaut)',
    RosaryColorTheme.monochrome: 'Monochrome',
    //RosaryColorTheme.aurora: 'Aurore Boréale',
    RosaryColorTheme.serenity: 'Sérénité',
    RosaryColorTheme.amber: 'Ambré',
    RosaryColorTheme.vegetal: 'Végétal',
    RosaryColorTheme.contemporain: 'Contemporain',
  };

  // Variable pour forcer la mise à jour du dialog
  final RxInt dialogUpdateTrigger = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  // Méthodes pour changer le style et le thème
  void changeStyle(RosaryStyle style) {
    currentStyle.value = style;
    // Incrémente la valeur pour forcer la mise à jour
    dialogUpdateTrigger.value++;
    savePreferences();
    update();
  }

  void changeColorTheme(RosaryColorTheme theme) {
    currentColorTheme.value = theme;
    // Incrémente la valeur pour forcer la mise à jour
    dialogUpdateTrigger.value++;
    savePreferences();
    update();
  }

  // Obtenir le texte du style actuel pour l'affichage
  String get currentStyleText => styleNames[currentStyle.value] ?? 'Classique';

  // Obtenir le texte du thème de couleur actuel pour l'affichage
  String get currentColorThemeText =>
      themeNames[currentColorTheme.value] ?? 'Original';

  void savePreferences() async {
    DB.saveData(KEY_ROSARY_STYLE, currentStyle.value.index.toString());
    DB.saveData(
        KEY_ROSARY_COLOR_THEME, currentColorTheme.value.index.toString());
  }

  // Chargement des préférences
  Future<void> loadPreferences() async {
    try {
      // Charger le style
      if (DB.encryptedBox?.containsKey(KEY_ROSARY_STYLE) == true) {
        final styleIndex = int.parse(DB.getData(KEY_ROSARY_STYLE) ?? '0');
        if (styleIndex >= 0 && styleIndex < RosaryStyle.values.length) {
          currentStyle.value = RosaryStyle.values[styleIndex];
        }
      }

      // Charger le thème de couleur
      if (DB.encryptedBox?.containsKey(KEY_ROSARY_COLOR_THEME) == true) {
        final themeIndex = int.parse(DB.getData(KEY_ROSARY_COLOR_THEME) ?? '0');
        if (themeIndex >= 0 && themeIndex < RosaryColorTheme.values.length) {
          currentColorTheme.value = RosaryColorTheme.values[themeIndex];
        }
      }

      update();
    } catch (e) {
      log('Erreur lors du chargement des préférences: $e');
    }
  }

  // Settings dialog
  void showSettingsDialog() {
    showModal(
        context: Get.context!,
        configuration: const FadeScaleTransitionConfiguration(
          transitionDuration: Duration(milliseconds: 350),
          reverseTransitionDuration: Duration(milliseconds: 100),
          barrierDismissible: true,
        ),
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        builder: (BuildContext context) {
          return Obx(() {
            // Force le widget à se reconstruire lorsque dialogUpdateTrigger change
            dialogUpdateTrigger.value;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // Limiter la largeur du dialogue pour éviter le débordement sur iOS
              insetPadding: EdgeInsets.symmetric(
                  horizontal: Platform.isIOS ? 30.0 : 40.0, vertical: 24.0),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Personnaliser le chapelet',
                      style: TextStyles.montserratBold(
                        textSize: TextSizes.eighteen,
                        textColor: colorGreenSemiLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Sélecteur de style
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      // Réduire le padding horizontal sur iOS
                      padding: EdgeInsets.symmetric(
                          horizontal: Platform.isIOS ? 8.0 : 20.0),
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
                          // Utiliser un conteneur avec contrainte de largeur sur iOS
                          Container(
                            constraints: Platform.isIOS
                                ? BoxConstraints(maxWidth: Get.width * 0.45)
                                : null,
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
                              isExpanded: Platform
                                  .isIOS, // Pour iOS, utiliser toute la largeur disponible
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
                                    overflow: TextOverflow
                                        .ellipsis, // Éviter le débordement du texte
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
                      // Réduire le padding horizontal sur iOS
                      padding: EdgeInsets.symmetric(
                          horizontal: Platform.isIOS ? 8.0 : 20.0),
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
                          // Utiliser un conteneur avec contrainte de largeur sur iOS
                          Container(
                            constraints: Platform.isIOS
                                ? BoxConstraints(maxWidth: Get.width * 0.45)
                                : null,
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
                              isExpanded: Platform
                                  .isIOS, // Pour iOS, utiliser toute la largeur disponible
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
                                        margin: const EdgeInsets.only(right: 6),
                                      ),
                                      // Nom du thème avec ellipsis pour éviter le débordement
                                      Flexible(
                                        child: Text(
                                          themeNames[theme] ?? '',
                                          style: TextStyles.montserratRegular(
                                            textSize: TextSizes.fourteen,
                                            textColor: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
        });
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
