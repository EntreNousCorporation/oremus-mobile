import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_menu_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/menu_grid_item.dart';

class MassRequestMenuScreen extends StatelessWidget {
  const MassRequestMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<MassRequestMenuController>(builder: (_) {
        return KeyboardDismisser(
          child: Column(
            children: [
              // En-tête de la section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorGreenSemiLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.church_outlined,
                        color: colorGreenSemiLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Services de messe et suivi',
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.seventeen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          Text(
                            'Gérez vos demandes et suivez leurs statuts',
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.thirteen,
                              textColor: Colors.grey[600]!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Grille des options
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (notification) {
                    notification.disallowIndicator();
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 4/3.5,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount: _.menus.length,
                    itemBuilder: (context, index) {
                      var menu = _.menus[index];
                      return MenuGridItem(item: menu);
                    },
                  ),
                ),
              ),

              // Section d'information en bas
              Visibility(
                visible: false,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorGreenSemiLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorGreenSemiLight.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Pourquoi utiliser ces services ?",
                        style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.fourteen,
                          textColor: colorGreenSemiLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vos demandes de messe sont importantes pour nous. Grâce à ces outils, vous pouvez facilement faire vos demandes, consulter votre historique et suivre toute réclamation en cas de besoin. Notre équipe paroissiale est à votre disposition pour vous accompagner.",
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.twelve,
                          textColor: Colors.grey[700]!,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
