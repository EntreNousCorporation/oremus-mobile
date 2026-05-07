import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

class WorshipSpecialHoursList extends StatelessWidget {
  const WorshipSpecialHoursList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestDateController>(
      builder: (controller) {
        if (controller.worshipSpecialHours.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: colorGrey1.withValues(alpha: 0.5),
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
          );
        }

        // Filtrer les messes spéciales selon les dates sélectionnées
        final startDate = Jiffy.parse(controller.initialSelectedDate.value?.day ?? '').dateTime;
        final endDate = Jiffy.parse(controller.endSelectedDate.value?.day ?? '').dateTime;
        final now = DateTime.now();
        final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche
        final isAfternoon = now.hour >= 12;

        final filteredSpecialMasses = controller.worshipSpecialHours.where((specialMass) {
          // Vérifie si la messe est dans la plage de dates sélectionnée
          final specialDate = Jiffy.parse(specialMass.day ?? '').dateTime;
          final isInDateRange = !specialDate.isBefore(startDate) && !specialDate.isAfter(endDate);

          // Si la messe n'est pas dans la plage de dates, elle n'est pas sélectionnable
          if (!isInDateRange) return false;

          // Si la messe est pour aujourd'hui, vérifier selon les règles du tableau
          if (isSameDay(specialDate, now)) {
            switch (currentWeekDay) {
              case 6: // Dimanche
              case 0: // Lundi
                return false; // Pas de messe disponible aujourd'hui
              case 1: // Mardi
              case 2: // Mercredi
              case 3: // Jeudi
              case 4: // Vendredi
              case 5: // Samedi
                return !isAfternoon; // Disponible uniquement avant 12h
            }
          }

          // Pour les autres jours, disponible si dans la plage de dates
          return isInDateRange;
        }).toList();

        if (filteredSpecialMasses.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: colorGrey1.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune messe spéciale disponible\npour la période sélectionnée',
                textAlign: TextAlign.center,
                style: TextStyles.montserratRegular(
                  textColor: colorGrey1,
                  textSize: TextSizes.fourteen,
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredSpecialMasses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final specialMass = filteredSpecialMasses[index];
            final specialDate = Jiffy.parse(specialMass.day ?? '').dateTime;
            final isToday = isSameDay(specialDate, now);

            // Vérifier si les horaires sont disponibles selon les règles
            final availableSlots = specialMass.slots?.where((slot) {
              if (!isToday) return true; // Tous les horaires sont disponibles pour les jours autres qu'aujourd'hui

              // Pour aujourd'hui, appliquer les règles du tableau
              final slotTime = parseTime(slot.startTime ?? '');

              switch (currentWeekDay) {
                case 1: // Mardi
                  return !isAfternoon && slotTime.hour >= 16;
                case 2: // Mercredi
                  return !isAfternoon && slotTime.hour >= 16;
                case 3: // Jeudi
                  return !isAfternoon && slotTime.hour >= 16;
                case 4: // Vendredi
                  return !isAfternoon && slotTime.hour >= 16;
                case 5: // Samedi
                  return !isAfternoon && slotTime.hour >= 16;
                default:
                  return false; // Dimanche et Lundi: pas de messe disponible
              }
            }).toList() ?? [];

            // Si aucun horaire n'est disponible, ne pas afficher cette messe
            if (availableSlots.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorGrey1.withValues(alpha: 0.4),
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
                    padding: const EdgeInsets.all(12),
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
                                specialMass.name ?? 'Messe spéciale',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.montserratBold(
                                  textColor: colorWhite,
                                  textSize: TextSizes.fifteen,
                                ),
                              ),
                              Text(
                                getCustomDate(specialMass.day, pattern: AppConstants.TIME_SIMPLE_FORMAT2),
                                style: TextStyles.montserratRegular(
                                  textColor: colorWhite.withValues(alpha: 0.9),
                                  textSize: TextSizes.fourteen,
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
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 5,
                          children: availableSlots.map((slot) {
                            final isSlotSelectable = isSlotAvailableForSpecialMass(slot.startTime, specialMass.day);

                            return FilterChip(
                              selected: controller.isSlotSelected(
                                  specialMass.day ?? '',
                                  slot.startTime ?? '',
                                  isSpecial: true
                              ),
                              onSelected: !isSlotSelectable
                                  ? (_) {
                                showNotification(
                                  message: 'Cette heure n\'est pas disponible',
                                  bgColor: colorBlue2,
                                );
                              }
                                  : (selected) {
                                controller.toggleSlotSelection(
                                    specialMass.day ?? '',
                                    slot.startTime ?? '',
                                    isSpecial: true
                                );
                              },
                              label: Text(slot.startTime ?? ''),
                              backgroundColor: colorWhite,
                              selectedColor: colorGreenSemiLight.withValues(alpha: 0.2),
                              checkmarkColor: colorGreenSemiLight,
                              labelStyle: TextStyles.montserratSemiBold(
                                textSize: TextSizes.fourteen,
                                textColor: controller.isSlotSelected(
                                    specialMass.day ?? '',
                                    slot.startTime ?? '',
                                    isSpecial: true
                                )
                                    ? colorGreenSemiLight
                                    : (isSlotSelectable ? colorBlack : colorGrey1),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSlotSelectable
                                      ? (controller.isSlotSelected(
                                      specialMass.day ?? '',
                                      slot.startTime ?? '',
                                      isSpecial: true
                                  )
                                      ? colorGreenSemiLight
                                      : colorGrey1.withValues(alpha: 0.3))
                                      : colorGrey1,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isSlotAvailableForSpecialMass(String? startTime, String? specialMassDate) {
    if (startTime == null || specialMassDate == null) return false;

    final specialDate = Jiffy.parse(specialMassDate).dateTime;
    final now = DateTime.now();

    // Si ce n'est pas aujourd'hui, l'horaire est disponible
    if (!isSameDay(specialDate, now)) return true;

    // Pour aujourd'hui, vérifier selon les règles du tableau
    final currentWeekDay = now.weekday - 1; // 0=lundi, 6=dimanche
    final isAfternoon = now.hour >= 12;
    final slotTime = parseTime(startTime);

    switch (currentWeekDay) {
      case 1: // Mardi
        return !isAfternoon && slotTime.hour >= 16;
      case 2: // Mercredi
        return !isAfternoon && slotTime.hour >= 16;
      case 3: // Jeudi
        return !isAfternoon && slotTime.hour >= 16;
      case 4: // Vendredi
        return !isAfternoon && slotTime.hour >= 16;
      case 5: // Samedi
        return !isAfternoon && slotTime.hour >= 16;
      default:
        return false; // Dimanche et Lundi: pas de messe disponible
    }
  }
}
