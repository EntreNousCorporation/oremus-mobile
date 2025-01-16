import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';

class WorshipRecurrentHoursList extends StatelessWidget {
  const WorshipRecurrentHoursList({Key? key}) : super(key: key);

  bool isFirstOccurrence(DateTime currentDayDate, DateTime ruleBasedDate) {
    return currentDayDate.year == ruleBasedDate.year &&
        currentDayDate.month == ruleBasedDate.month &&
        currentDayDate.day == ruleBasedDate.day;
  }

  bool isHourAvailable(String? startTime, DateTime currentDayDate, DateTime ruleBasedDate) {
    if (startTime == null) return false;
    final slotTime = parseTime(startTime);

    // Si c'est la première occurrence (déterminée par la règle du tableau)
    if (isFirstOccurrence(currentDayDate, ruleBasedDate)) {
      return slotTime.hour >= 12;  // Règle du tableau pour la première date valide
    }

    return true;  // Toutes les heures sont disponibles pour les occurrences suivantes
  }

  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestDateController>(
      builder: (_) {
        if (_.worshipRecurrentHours.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.repeat,
                  size: 48,
                  color: colorGrey1.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune messe régulière disponible\npour le moment',
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

        final now = DateTime.now();
        // Déterminer la date valide selon la règle du tableau
        final timeRange = _determineTimeRange(now);
        final ruleBasedDate = timeRange == TimeRange.evening
            ? DateTime.now().add(const Duration(days: 1))  // Lendemain si 15h01-00h00
            : DateTime.now();  // Même jour sinon

        // Trier les jours en fonction de leur sélectionnabilité
        final List<Map<String, dynamic>> sortedDays = _.worshipRecurrentHours.map((item) {
          bool isSelectable = isDayOfWeekInDateRange(
              int.parse(item.dayOfWeek ?? '0'),
              Jiffy.parse(_.initialSelectedDate.value?.day ?? '').dateTime,
              Jiffy.parse(_.endSelectedDate.value?.day ?? '').dateTime
          );
          return {
            'item': item,
            'isSelectable': isSelectable
          };
        }).toList();

        sortedDays.sort((a, b) {
          if (a['isSelectable'] && !b['isSelectable']) return -1;
          if (!a['isSelectable'] && b['isSelectable']) return 1;
          return int.parse(a['item'].dayOfWeek ?? '0')
              .compareTo(int.parse(b['item'].dayOfWeek ?? '0'));
        });

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDays.length,
          itemBuilder: (context, index) {
            var item = sortedDays[index]['item'];
            bool isSelectable = sortedDays[index]['isSelectable'];

            final dayOfWeek = int.parse(item.dayOfWeek ?? '0') + 1;
            final currentDayDate = getDateForDayOfWeek(ruleBasedDate, dayOfWeek);
            final isFirstDay = isFirstOccurrence(currentDayDate, ruleBasedDate);


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      getDay(int.parse(item.dayOfWeek ?? '')),
                      style: TextStyles.montserratSemiBold(
                        textColor: isSelectable ? colorPurpleLight : colorGrey1,
                        textSize: TextSizes.twenty,
                      ),
                    ),
                    if (!isSelectable) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorGrey1.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Non disponible',
                          style: TextStyles.montserratRegular(
                            textColor: colorGrey1,
                            textSize: TextSizes.twelve,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Separators.normalVertical(),
                Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 5,
                  spacing: 10,
                  direction: Axis.horizontal,
                  children: (item.slots ?? []).map<Widget>((slot) {
                    final isHourSelectable = isSelectable &&
                        isHourAvailable(slot.startTime, currentDayDate, ruleBasedDate);

                    final isSelected = _.isSlotSelected(
                        item.dayOfWeek ?? '0',
                        slot.startTime ?? ''
                    );

                    return FilterChip(
                      selected: isSelected,
                      onSelected: !isHourSelectable
                          ? (_) {
                        showNotification(
                          message: 'Cette heure n\'est pas disponible',
                          bgColor: colorBlue2,
                        );
                      }
                          : (bool selected) {
                        _.toggleSlotSelection(
                            item.dayOfWeek ?? '0',
                            slot.startTime ?? ''
                        );
                        _.onWorshipRecurrentHoursSelected(item, true);
                      },
                      label: Text(slot.startTime ?? ''),
                      backgroundColor: colorWhite,
                      selectedColor: colorGreenSemiLight.withOpacity(0.2),
                      checkmarkColor: colorGreenSemiLight,
                      labelStyle: TextStyles.montserratSemiBold(
                        textSize: TextSizes.fourteen,
                        textColor: isSelected
                            ? colorGreenSemiLight
                            : (isHourSelectable ? colorBlack : colorGrey1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isHourSelectable
                              ? (isSelected ? colorGreenSemiLight : colorGrey1.withOpacity(0.3))
                              : colorGrey1,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return Separators.normalVertical();
          },
        );
      },
    );
  }

  TimeRange _determineTimeRange(DateTime now) {
    final currentTime = now.hour * 60 + now.minute;
    if (currentTime >= 0 && currentTime <= 9 * 60) return TimeRange.morning;
    if (currentTime > 9 * 60 && currentTime <= 15 * 60) return TimeRange.afternoon;
    return TimeRange.evening;
  }

  DateTime getNextDateForDay(DateTime startDate, int targetDay) {
    DateTime date = startDate;
    while (date.weekday != targetDay) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  // Fonction utilitaire pour obtenir la date pour un jour de la semaine donné
  DateTime getDateForDayOfWeek(DateTime baseDate, int targetDayOfWeek) {
    // Si le jour cible est avant le jour de base, on passe à la semaine suivante
    while (baseDate.weekday != targetDayOfWeek) {
      baseDate = baseDate.add(const Duration(days: 1));
    }
    return baseDate;
  }
}