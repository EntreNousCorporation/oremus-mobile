import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_controller.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';

class PrayerIntentFilter extends StatelessWidget {
  const PrayerIntentFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestController>(builder: (logic) {
      return DropdownButtonFormField<PrayerIntentData?>(
        isExpanded: true,
        value: logic.prayerIntentSelected.value,
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
        items: logic.prayerIntents
            .map<DropdownMenuItem<PrayerIntentData?>>((PrayerIntentData? typeData) {
          return DropdownMenuItem<PrayerIntentData?>(
            value: typeData,
            child: Text(
              '${DB.getCurrentLanguage() == 'fr' ? typeData?.defaultText?.fr : typeData?.defaultText?.en}',
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
        onChanged: (PrayerIntentData? value) {
          logic.updatePrayerIntentFilter(value);
        },
      );
    });
  }
}
