import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/worship_recurrent_hours_list.dart';

class FilterMassRequestDateScreen extends StatelessWidget {
  const FilterMassRequestDateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope( //todo:- bien que déprecié, marche sur iPhones. Une solution sera trouvée plus tard
      onWillPop: () async {
        final _ = Get.find<FilterMassRequestDateController>();
        _.doBack();
        return false; // Empêche la navigation par défaut
      },
      child: Scaffold(
        backgroundColor: colorWhite,
        appBar: AppBar(
          backgroundColor: colorWhite,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorBlack),
            onPressed: () {
              final _ = Get.find<FilterMassRequestDateController>();
              _.doBack();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                final _ = Get.find<FilterMassRequestDateController>();
                _.doResetFilter();
              },
              child: Text(
                'Réinitialiser',
                style: TextStyles.montserratRegular(
                  textColor: colorBlack,
                ),
              ),
            ),
          ],
          title: Text(
            'Plusieurs messes',
            style: TextStyles.montserratBold(
              textColor: colorBlack,
              textSize: TextSizes.twenty,
            ),
          ),
        ),
        body: GetX<FilterMassRequestDateController>(
          builder: (_) => KeyboardDismisser(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Horaires récurrents
                          if (_.worshipRecurrentHours.isNotEmpty)
                            _buildRecurrentSection(_),

                          // Section Jours spéciaux (commenté pour l'instant)
                          // if (_.worshipSpecialHours.isNotEmpty)
                          //   _buildSpecialDaysSection(_),
                        ],
                      ),
                    ),
                  ),

                  // Bouton Continuer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: CustomButton(
                      text: 'Continuer',
                      textSize: TextSizes.eighteen,
                      actionColor: colorGreenSemiLight,
                      enabled: _.enabledApplyButton.value,
                      borderColor: _.enabledApplyButton.value ? colorGreen : colorGrey1,
                      bgcolor: _.enabledApplyButton.value ? colorGreen : colorGrey1,
                      action: () => _.moveToRecap(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire la section des horaires récurrents
  Widget _buildRecurrentSection(FilterMassRequestDateController _) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorPurpleLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Sélectionner les horaires de vos messes pour répétition',
            style: TextStyles.montserratSemiBold(
              textColor: colorWhite,
              textSize: TextSizes.sixteen,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Date de fin de la répétition',
          style: TextStyles.montserratMedium(
            textColor: colorGrey1,
            textSize: TextSizes.fourteen,
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () => _.selectDate(Get.context!, _.initialSelectedDate.value),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colorGrey2.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _.endSelectedDate.value?.dayToDisplay ?? '-',
                  style: TextStyles.montserratBold(
                    textColor: colorBlack,
                    textSize: TextSizes.sixteen,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: colorGreen,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        const WorshipRecurrentHoursList(),
      ],
    );
  }
}
