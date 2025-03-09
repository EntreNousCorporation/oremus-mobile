import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_menu_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/type_menu.dart';

class DonationMenuScreen extends StatelessWidget {
  const DonationMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<DonationMenuController>(builder: (_) {
        return KeyboardDismisser(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return false;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _.menus.length,
                  itemBuilder: (context, index) {
                    var menu = _.menus[index];
                    return _buildEnhancedMenuItem(menu);
                  },
                )),
          ),
        );
      }),
    );
  }

  Widget _buildEnhancedMenuItem(TypeMenu item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          item.goToPage.call();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône avec cercle de fond
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: colorGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  item.icon,
                  height: 35,
                  color: colorGreenSemiLight,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyles.montserratSemiBold(
                  textSize: 14,
                  textColor: Colors.black87,
                ),
              ),
            ),

            // Sous-titre ou description (si disponible)

          ],
        ),
      ),
    );
  }
}
