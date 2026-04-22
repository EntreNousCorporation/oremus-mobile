import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/reportproblem/controller/report_problem_controller.dart';

class ReportProblemDescriptionWidget extends StatelessWidget {
  const ReportProblemDescriptionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReportProblemController>(builder: (logic) {
      return TextFormField(
        controller: logic.descriptionController,
        keyboardAppearance: Brightness.light,
        style: TextStyles.montserratRegular(
          textColor: colorBlack,
          textSize: TextSizes.fourteen,
        ),
        maxLines: 6,
        minLines: 4,
        cursorColor: colorGreenSemiLight,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          filled: true,
          fillColor: colorGrey5,
          hintText: 'Décrivez le problème rencontré...',
          hintStyle: TextStyles.montserratRegular(
            textColor: Colors.grey[400]!,
            textSize: TextSizes.fourteen,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: colorGreenSemiLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        onChanged: (value) {
          logic.checkForm();
        },
      );
    });
  }
}