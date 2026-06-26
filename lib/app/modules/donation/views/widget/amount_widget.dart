import 'package:custom_input_formatter/custom_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_controller.dart';

class AmountWidget extends StatelessWidget {
  const AmountWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonationController>(builder: (logic) {
      return Container(
        decoration: BoxDecoration(
          color: colorGrey5,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: logic.amountFocusNode.hasFocus ? colorGreenSemiLight : Colors.grey[300]!,
            width: logic.amountFocusNode.hasFocus ? 2 : 1,
          ),
        ),
        child: TextFormField(
          controller: logic.amountController,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratBold(
            textColor: colorGreenSemiLight,
            textSize: TextSizes.seventeen,
          ),
          focusNode: logic.amountFocusNode,
          cursorColor: colorGreenSemiLight,
          keyboardType: TextInputType.number,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            hintText: 'Entrez le montant',
            hintStyle: TextStyles.montserratRegular(
              textColor: Colors.grey[500]!,
              textSize: TextSizes.sixteen,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                Icons.payments_rounded,
                color: logic.amountFocusNode.hasFocus || logic.amountController.text.isNotEmpty
                    ? colorGreenSemiLight
                    : Colors.grey[500],
                size: 24,
              ),
            ),
            suffixText: 'FCFA',
            suffixStyle: TextStyles.montserratBold(
              textColor: Colors.grey[800]!,
              textSize: TextSizes.fifteen,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
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
            logic.update();
          },
        ),
      );
    });
  }

  // ignore: unused_element
  Widget _buildQuickAmountButton(DonationController controller, String displayAmount, String amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.amountController.text = amount;
          controller.checkForm();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: colorGrey5,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            displayAmount,
            style: TextStyles.montserratSemiBold(
              textColor: colorGreenSemiLight,
              textSize: TextSizes.fourteen,
            ),
          ),
        ),
      ),
    );
  }
}