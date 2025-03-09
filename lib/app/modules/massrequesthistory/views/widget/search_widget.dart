import 'package:badges/badges.dart' as b;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestHistoryController>(builder: (logic) {
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
          suffixIcon: GestureDetector(
            onTap: () {
              logic.goToAdvancedSearch();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: b.Badge(
                  showBadge: (logic.searchCriteria.value.isMassRequestCriteriaEmpty == false),
                  position: b.BadgePosition.topEnd(top: -4, end: -4),
                  badgeColor: colorGreenSemiLight,
                  padding: const EdgeInsets.all(6),
                  badgeContent: Text(
                    '${logic.searchCriteria.value.countCriteria}',
                    style: TextStyles.montserratBold(
                      textColor: colorWhite,
                      textSize: TextSizes.eleven,
                    ),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: colorGreenSemiLight,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
