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
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: DropdownButtonFormField<TypeData?>(
          isExpanded: true,
          value: logic.claimTypeSelected.value,
          enableFeedback: true,
          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorGreenSemiLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: colorGreenSemiLight,
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          menuMaxHeight: 300,
          style: TextStyles.montserratSemiBold(
            textColor: Colors.black87,
            textSize: TextSizes.fifteen,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            isDense: false,
            filled: true,
            fillColor: Colors.white,
            labelText: '',
            hintText: 'Sélectionnez un type de réclamation',
            hintStyle: TextStyles.montserratRegular(
              textColor: Colors.grey[500]!,
              textSize: TextSizes.fifteen,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                Icons.category_outlined,
                color: colorGreenSemiLight,
                size: 20,
              ),
            ),
          ),
          items: logic.claimTypes
              .map<DropdownMenuItem<TypeData?>>((TypeData? typeData) {
            return DropdownMenuItem<TypeData?>(
              value: typeData,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  typeData?.name?.fr ?? '-',
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.montserratMedium(
                    textColor: Colors.black87,
                    textSize: TextSizes.fifteen,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (TypeData? value) {
            logic.updateClaimTypeFilter(value);
          },
        ),
      );
    });
  }
}
