import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/worship_recurrent_hours_list.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/worship_special_hours_list.dart';

class FilterMassRequestDateScreen extends StatelessWidget {
  const FilterMassRequestDateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = Get.find<FilterMassRequestDateController>();
        controller.doBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: colorWhite,
        appBar: AppBar(
          backgroundColor: colorGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorWhite),
            onPressed: () {
              final controller = Get.find<FilterMassRequestDateController>();
              controller.doBack();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                final controller = Get.find<FilterMassRequestDateController>();
                controller.doResetFilter();
              },
              child: Text(
                'Réinitialiser',
                style: TextStyles.montserratRegular(
                  textColor: colorWhite,
                ),
              ),
            ),
          ],
          title: Text(
            'Plusieurs messes',
            style: TextStyles.montserratBold(
              textColor: colorWhite,
              textSize: TextSizes.eighteen,
            ),
          ),
        ),
        body: GetX<FilterMassRequestDateController>(
          builder: (controller) => KeyboardDismisser(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec sélection de date
                _buildDateSelection(controller),

                // Contenu principal avec TabBarView
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // TabBar personnalisé
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: colorWhite,
                          child: Container(
                            height: 45,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorGrey1.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: colorGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelColor: colorWhite,
                              unselectedLabelColor: colorGrey1,
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.repeat, size: 18, color: colorBlack,),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Messes régulières',
                                          style: TextStyles.montserratMedium(
                                            textSize: TextSizes.fourteen,
                                            textColor: colorBlack,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.event_note, size: 18, color: colorBlack,),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Messes spéciales',
                                          style: TextStyles.montserratMedium(
                                            textSize: TextSizes.fourteen,
                                            textColor: colorBlack,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Contenu des tabs
                        const Expanded(
                          child: TabBarView(
                            children: [
                              // Tab des messes régulières
                              SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: WorshipRecurrentHoursList(),
                              ),

                              // Tab des messes spéciales
                              SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: WorshipSpecialHoursList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bouton de continuation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Continuer',
                    textSize: TextSizes.eighteen,
                    actionColor: colorGreenSemiLight,
                    enabled: controller.enabledApplyButton.value,
                    borderColor: controller.enabledApplyButton.value ? colorGreen : colorGrey1,
                    bgcolor: controller.enabledApplyButton.value ? colorGreen : colorGrey1,
                    action: () => controller.moveToRecap(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelection(FilterMassRequestDateController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Période de répétition',
            style: TextStyles.montserratMedium(
              textColor: colorGrey1,
              textSize: TextSizes.fourteen,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateBox(
                  'Du',
                  controller.initialSelectedDate.value?.dayToDisplay ?? '-',
                  onTap: () => controller.selectStartDate(Get.context!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateBox(
                  'Au',
                  controller.endSelectedDate.value?.dayToDisplay ?? '-',
                  onTap: () => controller.selectEndDate(Get.context!, controller.initialSelectedDate.value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, String date, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorGreenSemiLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyles.montserratRegular(
                textColor: colorGrey1,
                textSize: TextSizes.twelve,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyles.montserratBold(
                    textColor: colorBlack,
                    textSize: TextSizes.fourteen,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: colorGreenSemiLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
