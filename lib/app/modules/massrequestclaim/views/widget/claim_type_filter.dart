import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/controller/mass_request_claim_controller.dart';

class ClaimTypeFilter extends StatelessWidget {
  const ClaimTypeFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestClaimController>(builder: (logic) {
      return DropdownButtonFormField<TypeData?>(
        isExpanded: true,
        value: logic.claimTypeSelected.value,
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
          labelText: '',
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
        items: logic.claimTypes
            .map<DropdownMenuItem<TypeData?>>((TypeData? typeData) {
          return DropdownMenuItem<TypeData?>(
            value: typeData,
            child: Text(
              typeData?.name?.fr ?? '-',
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
        onChanged: (TypeData? value) {
          logic.updateClaimTypeFilter(value);
        },
      );
    });
  }
}
