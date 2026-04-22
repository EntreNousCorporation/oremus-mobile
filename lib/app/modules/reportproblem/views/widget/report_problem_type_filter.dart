import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/reportproblem/controller/report_problem_controller.dart';
import 'package:oremusapp/app/modules/reportproblem/data/model/report_problem_data.dart';

class ReportProblemTypeFilter extends StatelessWidget {
  const ReportProblemTypeFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportProblemController>(builder: (logic) {
      return Container(
        decoration: BoxDecoration(
          color: colorGrey5,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: logic.reportProblemTypeSelected.value != null
                ? colorGreenSemiLight
                : Colors.grey[300]!,
            width: logic.reportProblemTypeSelected.value != null ? 1.5 : 1,
          ),
        ),
        child: DropdownButtonFormField<ReportProblemTypeData?>(
          isExpanded: true,
          value: logic.reportProblemTypeSelected.value,
          enableFeedback: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: colorGreenSemiLight,
          ),
          iconSize: 24,
          iconEnabledColor: colorGreenSemiLight,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            isDense: true,
            hintText: 'Sélectionnez le type de problème',
            hintStyle: TextStyles.montserratRegular(
              textColor: Colors.grey[400]!,
              textSize: TextSizes.fourteen,
            ),
            prefixIcon: logic.reportProblemTypeSelected.value != null
                ? const Icon(
              Icons.error_outline,
              color: colorGreenSemiLight,
              size: 20,
            )
                : null,
          ),
          style: TextStyles.montserratMedium(
            textColor: colorBlack,
            textSize: TextSizes.fourteen,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: logic.reportProblemTypes
              .map<DropdownMenuItem<ReportProblemTypeData?>>(
                  (ReportProblemTypeData? typeData) {
                return DropdownMenuItem<ReportProblemTypeData?>(
                  value: typeData,
                  child: Text(
                    typeData?.name?.fr ?? '-',
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.montserratMedium(
                      textColor: colorBlack,
                      textSize: TextSizes.fourteen,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (ReportProblemTypeData? value) {
            logic.updateReportProblemTypeFilter(value);
          },
        ),
      );
    });
  }
}
