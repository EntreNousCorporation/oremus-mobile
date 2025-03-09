import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequestclaim/controller/mass_request_claim_controller.dart';

class ClaimTypeWidget extends StatelessWidget {
  const ClaimTypeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestClaimController>(builder: (logic) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextFormField(
          controller: logic.claimDescription,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratMedium(
            textColor: Colors.black87,
            textSize: TextSizes.fifteen,
          ),
          maxLines: 6,
          cursorColor: colorGreenSemiLight,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Décrivez votre réclamation en détail...',
            hintStyle: TextStyles.montserratRegular(
              textColor: Colors.grey[400]!,
              textSize: TextSizes.fourteen,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: colorGreenSemiLight,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 14, bottom: 14),
              child: Icon(
                Icons.description_outlined,
                color: logic.claimDescription.text.isNotEmpty
                    ? colorGreenSemiLight
                    : Colors.grey[400],
                size: 20,
              ),
            ),
          ),
          onChanged: (value) {
            logic.checkForm();
            logic.update();
          },
        ),
      );
    });
  }
}
