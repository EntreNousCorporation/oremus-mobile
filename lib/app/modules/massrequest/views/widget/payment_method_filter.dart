import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_recap_controller.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';

class PaymentMethodFilter extends StatelessWidget {
  const PaymentMethodFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestRecapController>(builder: (logic) {
      return DropdownButtonFormField<PaymentMethodData?>(
        isExpanded: true,
        initialValue: logic.paymentMethodSelected.value,
        enableFeedback: true,
        icon: const Icon(
          Icons.arrow_drop_down_rounded,
          size: 25,
        ),
        iconEnabledColor: colorGreen,
        style: TextStyles.montserratBold(textSize: TextSizes.eighteen),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(
            12,
            10,
            12,
            10,
          ),
          isDense: false,
          labelText: 'Choisir un mode de paiement',
          labelStyle: TextStyles.montserratRegular(
            textColor: colorBlack,
            textSize: TextSizes.sixteen,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorGreen),
            borderRadius: BorderRadius.circular(4),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorTransparent),
            borderRadius: BorderRadius.circular(4),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: colorGrey1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        items: logic.paymentMethods
            .map<DropdownMenuItem<PaymentMethodData?>>((PaymentMethodData? paymentMethod) {
          return DropdownMenuItem<PaymentMethodData?>(
            value: paymentMethod,
            child: Text(
              paymentMethod?.name?.fr ?? '-',
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.montserratMedium(
                textColor: colorBlack,
                textSize: TextSizes.sixteen,
              ),
            ),
          );
        }).toList(),
        onChanged: (PaymentMethodData? value) {
          logic.paymentMethodSelected.value = value;
          logic.checkForm();
        },
      );
    });
  }
}
