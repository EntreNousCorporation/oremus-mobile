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
      child: GetX<DonationMenuController>(builder: (controller) {
        return KeyboardDismisser(
          child: Column(
            children: [
              // En-tête de la section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            'Services de dons & offrandes',
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.seventeen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          Text(
                            'Soutenez Orémus et vos paroisses en toute confiance. Chaque don est reversé sous 7 jours maximum après un traitement sécurisé. Une commission de 10% est prélevée pour les frais de service. Merci de votre générosité.',
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
                    itemCount: controller.menus.length,
                    itemBuilder: (context, index) {
                      var menu = controller.menus[index];
                      return MenuGridItem(item: menu);
                    },
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
