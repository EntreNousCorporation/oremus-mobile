import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/image_displayer.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_menu_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/menu_grid_item.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationMenuScreen extends StatelessWidget {
  const DonationMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<DonationMenuController>(builder: (_) {
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
                        child: const ImageDisplayer(
                          icon: Assets.imagesVolunteer,
                          height: 20,
                          color: colorGreenSemiLight,
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soutenir la paroisse',
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.seventeen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          Text(
                            'Choisissez une action à effectuer',
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

              // Grille des options de don
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (notification) {
                    notification.disallowIndicator();
                    return false;
                  },
                  child: GridView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 4/3.2,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
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
                        "Vos dons sont déductibles des impôts",
                        style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.fourteen,
                          textColor: colorGreenSemiLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Un reçu fiscal vous sera envoyé pour tout don effectué",
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
