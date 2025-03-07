import 'package:custom_input_formatter/custom_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_controller.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_with_worship_controller.dart';

class AmountWidget extends StatelessWidget {
  const AmountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonationController>(builder: (logic) {
      return Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10,
        color: colorWhite,
        shadowColor: colorGrey2.withOpacity(0.5),
        child: TextFormField(
          controller: logic.amountController,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratSemiBold(textColor: colorBlack),
          focusNode: logic.amountFocusNode,
          cursorColor: colorBlue,
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.words,
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
          inputFormatters: [
            CustomNumberInputFormatter(
              formatType: FormatType.amount,
            ),
            FilteringTextInputFormatter.allow(RegExp(AppConstants.INPUT_NUM_REGEX)),
            FilteringTextInputFormatter.deny(RegExp(r'^0')),
          ],
          onChanged: (value) {
            logic.checkForm();
          },
        ),
      );
    });
  }
}
