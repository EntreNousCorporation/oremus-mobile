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
      return Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10,
        color: colorWhite,
        shadowColor: colorGrey2.withValues(alpha: 0.5),
        child: TextFormField(
          controller: logic.claimDescription,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratSemiBold(textColor: colorBlack),
          maxLines: 6,
          cursorColor: colorBlue,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
            filled: true,
            fillColor: colorWhite,
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorGreen),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorTransparent),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: InputBorder.none,
            disabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: colorGrey1),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: '',
            hintStyle: TextStyles.montserratItalic(
              textColor: colorPurpleLight,
              textSize: TextSizes.fourteen,
            ),
          ),
          onChanged: (value) {
            logic.checkForm();
          },
        ),
      );
    });
  }
}
