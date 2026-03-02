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

  bool isHourAvailable_(String? startTime, DateTime currentDayDate, DateTime ruleBasedDate) {
    if (startTime == null) return false;
    final slotTime = parseTime(startTime);

    // Si c'est la première occurrence (déterminée par la règle du tableau)
    if (isFirstOccurrence(currentDayDate, ruleBasedDate)) {
      return slotTime.hour >= 12;  // Règle du tableau pour la première date valide
    }

    return true;  // Toutes les heures sont disponibles pour les occurrences suivantes
  }

  bool isHourAvailable(String? startTime, DateTime currentDayDate, DateTime ruleBasedDate) {
    if (startTime == null) return false;
    late FilterMassRequestDateController controller;

    if (Get.isRegistered<FilterMassRequestDateController>()) {
      controller = Get.find<FilterMassRequestDateController>();
    } else {
      Get.lazyPut(()=>FilterMassRequestDateController());
      controller = Get.find<FilterMassRequestDateController>();
    }

    // Si une date de fin a été sélectionnée, on ignore les règles du tableau
    if (controller.endSelectedDate.value?.dayToDisplay != null &&
        controller.endSelectedDate.value?.dayToDisplay != '-') {
      return true;
    }

    final slotTime = parseTime(startTime);

    // Convertir le jour de la semaine Dart (1-7) au format de l'application (0-6)
    // Dans l'application: 0=lundi, 1=mardi, ..., 6=dimanche
    // Dans Dart: 1=lundi, 2=mardi, ..., 7=dimanche
    int currentWeekDay = DateTime.now().weekday - 1; // 0 pour lundi, 6 pour dimanche

    // Obtenir le jour de la semaine cible au format de l'application
    int targetWeekDay = currentDayDate.weekday - 1; // 0 pour lundi, 6 pour dimanche

    // Vérifier l'heure actuelle
    final now = DateTime.now();
    final isAfternoon = now.hour >= 12;

    // Appliquer les règles du tableau
    switch (currentWeekDay) {
      case 6: // Dimanche (6)
      // Si le jour cible est mardi (1)
        if (targetWeekDay == 1) { // Mardi
          return slotTime.hour >= 12;
        }
        break;

      case 0: // Lundi (0)
        if (targetWeekDay == 1) { // Mardi
          return slotTime.hour >= 12;
        }
        break;

      case 1: // Mardi (1)
        if (targetWeekDay == 1) { // Mardi (même jour)
          if (!isAfternoon) { // Avant 12h00
            return slotTime.hour >= 16;
          } else { // Après 12h00
            return false; // Pas de messe disponible le même jour après 12h
          }
        } else if (targetWeekDay == 2) { // Mercredi
          return isAfternoon && slotTime.hour >= 12; // Disponible si demandé après 12h
        }
        break;

      case 2: // Mercredi (2)
        if (targetWeekDay == 2) { // Mercredi (même jour)
          if (!isAfternoon) { // Avant 12h00
            return slotTime.hour >= 16;
          } else { // Après 12h00
            return false; // Pas de messe disponible le même jour après 12h
          }
        } else if (targetWeekDay == 3) { // Jeudi
          return isAfternoon && slotTime.hour >= 12; // Disponible si demandé après 12h
        }
        break;

      case 3: // Jeudi (3)
        if (targetWeekDay == 3) { // Jeudi (même jour)
          if (!isAfternoon) { // Avant 12h00
            return slotTime.hour >= 16;
          } else { // Après 12h00
            return false; // Pas de messe disponible le même jour après 12h
          }
        } else if (targetWeekDay == 4) { // Vendredi
          return isAfternoon && slotTime.hour >= 12; // Disponible si demandé après 12h
        }
        break;

      case 4: // Vendredi (4)
        if (targetWeekDay == 4) { // Vendredi (même jour)
          if (!isAfternoon) { // Avant 12h00
            return slotTime.hour >= 16;
          } else { // Après 12h00
            return false; // Pas de messe disponible le même jour après 12h
          }
        } else if (targetWeekDay == 5) { // Samedi
          return isAfternoon && slotTime.hour >= 12; // Disponible si demandé après 12h
        }
        break;

      case 5: // Samedi (5)
        if (targetWeekDay == 5) { // Samedi (même jour)
          if (!isAfternoon) { // Avant 12h00
            return slotTime.hour >= 16;
          } else { // Après 12h00
            return false; // Pas de messe disponible le même jour après 12h
          }
        } else if (targetWeekDay == 1) { // Mardi
          return isAfternoon && slotTime.hour >= 12; // Disponible si demandé après 12h
        }
        break;
    }

    // Par défaut, toutes les heures sont disponibles pour les autres jours
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return GetX<FilterMassRequestDateController>(
      builder: (controller) {
        if (controller.worshipRecurrentHours.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.repeat,
                  size: 48,
                  color: colorGrey1.withValues(alpha: 0.5),
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
        // Déterminer la date valide selon les règles du grand tableau
        final currentWeekDay = now.weekday - 1; // 0 pour lundi, 6 pour dimanche
        final isAfternoon = now.hour >= 12;

        // Déterminer la date de référence pour les règles
        DateTime ruleBasedDate;

        switch (currentWeekDay) {
          case 6: // Dimanche (6)
          // Pour dimanche, la prochaine date valide est mardi
            ruleBasedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi
            break;
          case 0: // Lundi (0)
          // Pour lundi, la prochaine date valide est mardi
            ruleBasedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi
            break;
          case 1: // Mardi (1)
            if (!isAfternoon) {
              // Avant 12h: le même jour (mardi) à 16h
              ruleBasedDate = now;
            } else {
              // Après 12h: mercredi à 12h
              ruleBasedDate = _findNextDayOfWeek(now, 2); // 2 = Mercredi
            }
            break;
          case 2: // Mercredi (2)
            if (!isAfternoon) {
              // Avant 12h: le même jour (mercredi) à 16h
              ruleBasedDate = now;
            } else {
              // Après 12h: jeudi à 12h
              ruleBasedDate = _findNextDayOfWeek(now, 3); // 3 = Jeudi
            }
            break;
          case 3: // Jeudi (3)
            if (!isAfternoon) {
              // Avant 12h: le même jour (jeudi) à 16h
              ruleBasedDate = now;
            } else {
              // Après 12h: vendredi à 12h
              ruleBasedDate = _findNextDayOfWeek(now, 4); // 4 = Vendredi
            }
            break;
          case 4: // Vendredi (4)
            if (!isAfternoon) {
              // Avant 12h: le même jour (vendredi) à 16h
              ruleBasedDate = now;
            } else {
              // Après 12h: samedi à 12h
              ruleBasedDate = _findNextDayOfWeek(now, 5); // 5 = Samedi
            }
            break;
          case 5: // Samedi (5)
            if (!isAfternoon) {
              // Avant 12h: le même jour (samedi) à 16h
              ruleBasedDate = now;
            } else {
              // Après 12h: mardi à 12h
              ruleBasedDate = _findNextDayOfWeek(now, 1); // 1 = Mardi
            }
            break;
          default:
            ruleBasedDate = now;
            break;
        }

        // Trier les jours en fonction de leur sélectionnabilité
        final List<Map<String, dynamic>> sortedDays = controller.worshipRecurrentHours.map((item) {
          bool isSelectable = isDayOfWeekInDateRange(
              int.parse(item.dayOfWeek ?? '0'),
              Jiffy.parse(controller.initialSelectedDate.value?.day ?? '').dateTime,
              Jiffy.parse(controller.endSelectedDate.value?.day ?? '').dateTime
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
                          color: colorGrey1.withValues(alpha: 0.2),
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

                    final isSelected = controller.isSlotSelected(
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
                        controller.toggleSlotSelection(
                            item.dayOfWeek ?? '0',
                            slot.startTime ?? ''
                        );
                        controller.onWorshipRecurrentHoursSelected(item, true);
                      },
                      label: Text(slot.startTime ?? ''),
                      backgroundColor: colorWhite,
                      selectedColor: colorGreenSemiLight.withValues(alpha: 0.2),
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
                              ? (isSelected ? colorGreenSemiLight : colorGrey1.withValues(alpha: 0.3))
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

  DateTime _findNextDayOfWeek(DateTime from, int dayOfWeek) {
    DateTime result = DateTime(from.year, from.month, from.day);

    // Convertir dayOfWeek du format de l'application (0-6) au format Dart (1-7)
    int dartDayOfWeek = dayOfWeek + 1;

    while (result.weekday != dartDayOfWeek) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  TimeRange _determineTimeRange(DateTime now) {
    final currentHour = now.hour;
    final currentMinute = now.minute;

    // Utiliser le format 24h pour la comparaison
    final currentTimeInMinutes = currentHour * 60 + currentMinute;

    if (currentTimeInMinutes >= 0 && currentTimeInMinutes < 12 * 60) {
      return TimeRange.morning; // 00h01 - 12h00
    } else {
      return TimeRange.afternoon; // 12h01 - 24h00
    }
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