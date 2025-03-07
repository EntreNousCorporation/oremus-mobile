import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/filter_donation_history_controller.dart';

class MassRequestTypeSearchWidget extends StatelessWidget {
  const MassRequestTypeSearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterDonationHistoryController>(builder: (logic) {
      return Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10,
        color: colorWhite,
        shadowColor: colorGrey2.withOpacity(0.5),
        child: TextFormField(
          controller: logic.typeMassRequestSearchController,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratMedium(textColor: colorBlack),
          maxLines: 1,
          cursorColor: colorBlue,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
            filled: true,
            fillColor: colorWhite,
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorWhite),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorWhite),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: 'Faire une recherche...',
            hintStyle: TextStyles.montserratItalic(
                textColor: colorPurpleLight, textSize: TextSizes.fourteen),
            suffixIcon: logic.isMassRequestSearchFieldEmpty.isFalse
                ? FadeIn(
                    child: IconButton(
                      onPressed: () {
                        //clean search bar
                        logic.resetMassRequestTypeSearch();
                      },
                      icon: const Icon(Icons.cancel,
                          color: colorPurpleLight, size: 20),
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            logic.isMassRequestSearchFieldEmpty.value = value.isEmpty;
            logic.updateMassRequestTypeFilter(value);
            if (value.isEmpty) {
              logic.resetMassRequestTypeSearch();
            }
          },
        ),
      );
    });
  }
}
