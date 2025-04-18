import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class RosaryController extends GetxController {

  RosaryController();

  var unlockBackButton = true.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
   super.dispose();
  }


  // Settings dialog
  void showSettingsDialog() {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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

                // Language selection
                _buildSettingsRow(
                  'Langue',
                  DropdownButton<String>(
                    value: 'Français',
                    underline: Container(),
                    items: ['Français', 'English', 'Español', 'Italiano'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),

                const SizedBox(height: 16),

                // Voice selection
                _buildSettingsRow(
                  'Voix',
                  DropdownButton<String>(
                    value: 'Homme',
                    underline: Container(),
                    items: ['Homme', 'Femme', 'Chorale'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),

                const SizedBox(height: 16),

                // Background music
                _buildSettingsRow(
                  'Musique de fond',
                  Switch(
                    value: true,
                    activeColor: colorGreenSemiLight,
                    onChanged: (_) {},
                  ),
                ),

                const SizedBox(height: 16),

                // Volume control
                _buildSettingsRow(
                  'Volume',
                  SizedBox(
                    width: 150,
                    child: Slider(
                      value: 0.7,
                      activeColor: colorGreenSemiLight,
                      onChanged: (_) {},
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGreenSemiLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
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
      },
    );
  }

  // Helper method for settings rows
  Widget _buildSettingsRow(String label, Widget control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.montserratMedium(
            textSize: TextSizes.fifteen,
            textColor: Colors.black87,
          ),
        ),
        control,
      ],
    );
  }


  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }
}
