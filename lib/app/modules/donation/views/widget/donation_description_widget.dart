import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_controller.dart';

class DonationDescriptionWidget extends StatelessWidget {
  const DonationDescriptionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonationController>(builder: (logic) {
      return TextFormField(
        controller: logic.descriptionController,
        keyboardAppearance: Brightness.light,
        style: TextStyles.montserratMedium(
          textColor: colorBlack,
          textSize: TextSizes.fifteen,
        ),
        maxLines: 6,
        cursorColor: colorGreenSemiLight,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          filled: true,
          fillColor: Colors.grey[50],
          hintText: 'Partagez l\'intention de votre don...',
          hintStyle: TextStyles.montserratItalic(
            textColor: Colors.grey[500]!,
            textSize: TextSizes.fourteen,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorGreenSemiLight, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8, top: 12),
            child: Icon(
              Icons.edit_note_rounded,
              color: logic.descriptionController.text.isNotEmpty
                  ? colorGreenSemiLight
                  : Colors.grey[400],
            ),
          ),
        ),
        onChanged: (value) {
          logic.checkForm();
          logic.update();
        },
      );
    });
  }
}