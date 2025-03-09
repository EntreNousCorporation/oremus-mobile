import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/filter_mass_request_history_controller.dart';

class MassRequestTypeSearchWidget extends StatelessWidget {
  const MassRequestTypeSearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestHistoryController>(builder: (logic) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: logic.typeMassRequestSearchController,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratMedium(
            textColor: Colors.black87,
            textSize: TextSizes.fifteen,
          ),
          maxLines: 1,
          cursorColor: colorGreenSemiLight,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: colorGreenSemiLight,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: 'Rechercher un type de messe...',
            hintStyle: TextStyles.montserratRegular(
              textColor: Colors.grey[400]!,
              textSize: TextSizes.fourteen,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                Icons.search_rounded,
                color: logic.typeMassRequestSearchController.text.isNotEmpty
                    ? colorGreenSemiLight
                    : Colors.grey[400],
                size: 20,
              ),
            ),
            suffixIcon: logic.isMassRequestSearchFieldEmpty.isFalse
                ? FadeIn(
              child: GestureDetector(
                onTap: () {
                  //clean search bar
                  logic.resetMassRequestTypeSearch();
                },
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorGreenSemiLight.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: colorGreenSemiLight,
                    size: 16,
                  ),
                ),
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
