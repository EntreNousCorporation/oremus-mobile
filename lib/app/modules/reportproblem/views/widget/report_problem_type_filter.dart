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
      return DropdownButtonFormField<ReportProblemTypeData?>(
        isExpanded: true,
        value: logic.reportProblemTypeSelected.value,
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
        items: logic.reportProblemTypes
            .map<DropdownMenuItem<ReportProblemTypeData?>>((ReportProblemTypeData? typeData) {
          return DropdownMenuItem<ReportProblemTypeData?>(
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
        onChanged: (ReportProblemTypeData? value) {
          logic.updateReportProblemTypeFilter(value);
        },
      );
    });
  }
}
