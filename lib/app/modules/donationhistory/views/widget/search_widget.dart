import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_controller.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonationHistoryController>(builder: (logic) {
      return TextFormField(
        controller: logic.searchController,
        keyboardAppearance: Brightness.light,
        style: TextStyles.montserratMedium(textColor: colorBlack),
        maxLines: 1,
        cursorColor: colorBlue,
        keyboardType: TextInputType.text,
        onTap: () {
          logic.showRangeDatePicker();
        },
        readOnly: true,
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
          hintText: 'Choisir une période...',
          hintStyle: TextStyles.montserratItalic(
              textColor: colorPurpleLight, textSize: TextSizes.fourteen),
        ),
      );
    });
  }
}
