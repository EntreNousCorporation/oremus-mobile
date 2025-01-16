import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/worship_recurrent_hours_list.dart';

class FilterMassRequestDateScreen extends StatelessWidget {
  const FilterMassRequestDateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final _ = Get.find<FilterMassRequestDateController>();
        _.doBack();
        return false;
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
              textSize: TextSizes.seventeen,
            ),
          ),
        ),
        body: GetX<FilterMassRequestDateController>(
          builder: (_) => KeyboardDismisser(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête avec sélection de date
                _buildDateSelection(_),

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
                              color: colorGrey1.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: colorGreenSemiLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelColor: colorWhite,
                              unselectedLabelColor: colorGrey1,
                              tabs: [
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.repeat, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Régulières',
                                        style: TextStyles.montserratMedium(
                                          textSize: TextSizes.fourteen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tab(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.event_note, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Spéciales',
                                        style: TextStyles.montserratMedium(
                                          textSize: TextSizes.fourteen,
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
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Tab des messes régulières
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: const WorshipRecurrentHoursList(),
                              ),

                              // Tab des messes spéciales
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: _buildSpecialMassesList(_),
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
    );
  }

  Widget _buildDateSelection(FilterMassRequestDateController _) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
                  _.initialSelectedDate.value?.dayToDisplay ?? '-',
                  onTap: null, // Date de début non modifiable
                  enabled: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateBox(
                  'Au',
                  _.endSelectedDate.value?.dayToDisplay ?? '-',
                  onTap: () => _.selectDate(Get.context!, _.initialSelectedDate.value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, String date, {VoidCallback? onTap, bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? colorWhite : colorGrey1.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? colorGreenSemiLight : colorGrey1.withOpacity(0.2),
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
                    textColor: enabled ? colorBlack : colorGrey1,
                    textSize: TextSizes.fourteen,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: enabled ? colorGreenSemiLight : colorGrey1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialMassesList(FilterMassRequestDateController _) {
    if (_.worshipSpecialHours.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: colorGrey1.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune messe spéciale disponible\npour le moment',
              textAlign: TextAlign.center,
              style: TextStyles.montserratRegular(
                textColor: colorGrey1,
                textSize: TextSizes.fourteen,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _.worshipSpecialHours.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final specialMass = _.worshipSpecialHours[index];
        return Container(
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: colorGreenSemiLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_note,
                      color: colorWhite,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            /*specialMass.title ?? */'Messe spéciale',
                            style: TextStyles.montserratBold(
                              textColor: colorWhite,
                              textSize: TextSizes.fourteen,
                            ),
                          ),
                          Text(
                            getCustomDate(specialMass.day, pattern: AppConstants.TIME_SIMPLE_FORMAT2),
                            style: TextStyles.montserratRegular(
                              textColor: colorWhite.withOpacity(0.9),
                              textSize: TextSizes.twelve,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des horaires
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horaires disponibles',
                      style: TextStyles.montserratMedium(
                        textColor: colorGrey1,
                        textSize: TextSizes.twelve,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: specialMass.slots?.map((slot) {
                        return FilterChip(
                          selected: _.isSlotSelected(
                            specialMass.day ?? '',
                            slot.startTime ?? '',
                              isSpecial: true
                          ),
                          onSelected: (selected) {
                            _.toggleSlotSelection(
                              specialMass.day ?? '',
                              slot.startTime ?? '',
                                isSpecial: true
                            );
                          },
                          label: Text(slot.startTime ?? ''),
                          backgroundColor: colorWhite,
                          selectedColor: colorGreenSemiLight.withOpacity(0.2),
                          checkmarkColor: colorGreenSemiLight,
                          labelStyle: TextStyles.montserratMedium(
                            textSize: TextSizes.fourteen,
                            textColor: _.isSlotSelected(
                              specialMass.dayOfWeek ?? '0',
                              slot.startTime ?? '',
                            )
                                ? colorGreenSemiLight
                                : colorBlack,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _.isSlotSelected(
                                specialMass.dayOfWeek ?? '0',
                                slot.startTime ?? '',
                              )
                                  ? colorGreenSemiLight
                                  : colorGrey1.withOpacity(0.3),
                            ),
                          ),
                        );
                      }).toList() ??
                          [],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
