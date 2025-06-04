import 'dart:developer';
import 'package:device_calendar/device_calendar.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  DeviceCalendarPlugin? _deviceCalendarPlugin;
  Calendar? _oremusCalendar;

  static const String OREMUS_CALENDAR_NAME = "Oremus - Plans de Vie";
  static const String EVENT_PREFIX = "OREMUS_LIFEPLAN_";

  DeviceCalendarPlugin get _calendar {
    _deviceCalendarPlugin ??= DeviceCalendarPlugin();
    return _deviceCalendarPlugin!;
  }

  /// Vérifie et demande les permissions calendrier
  Future<bool> requestCalendarPermission() async {
    try {
      var permissionsGranted = await _calendar.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
        return true;
      }

      permissionsGranted = await _calendar.requestPermissions();
      return permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
    } catch (e) {
      log('Erreur permissions calendrier: $e');
      return false;
    }
  }

  /// Trouve ou crée le calendrier Oremus
  Future<Calendar?> _getOrCreateOremusCalendar() async {
    if (_oremusCalendar != null) return _oremusCalendar;

    try {
      final calendarsResult = await _calendar.retrieveCalendars();
      if (!calendarsResult.isSuccess) return null;

      final calendars = calendarsResult.data ?? [];

      // Chercher le calendrier Oremus existant
      _oremusCalendar = calendars.firstWhereOrNull(
              (cal) => cal.name == OREMUS_CALENDAR_NAME
      );

      // Si pas trouvé, essayer de le créer (Android seulement)
      _oremusCalendar ??= calendars.firstWhereOrNull(
                (cal) => cal.isDefault == true
        );

      return _oremusCalendar;
    } catch (e) {
      log('Erreur récupération calendrier: $e');
      return null;
    }
  }

  /// Ajoute les créneaux d'un plan de vie au calendrier
  Future<bool> addLifePlanToCalendar(UserLifePlan userLifePlan) async {
    try {
      if (!await requestCalendarPermission()) {
        log('Permissions calendrier refusées');
        return false;
      }

      final calendar = await _getOrCreateOremusCalendar();
      if (calendar == null) {
        log('Impossible de récupérer le calendrier');
        return false;
      }

      final planName = userLifePlan.lifePlan?.name?.fr ?? 'Plan de vie';
      final slots = userLifePlan.slots ?? [];

      for (int i = 0; i < slots.length; i++) {
        final slot = slots[i];
        if (slot.hour == null || slot.minute == null) continue;

        final success = await _createRecurringEvent(
          calendar: calendar,
          planId: userLifePlan.identifier ?? 0,
          slotIndex: i,
          planName: planName,
          hour: slot.hour!,
          minute: slot.minute!,
        );

        if (!success) {
          log('Échec création événement pour $planName à ${slot.getFormattedTime()}');
        }
      }

      return true;
    } catch (e) {
      log('Erreur ajout plan au calendrier: $e');
      return false;
    }
  }

  /// Crée un événement récurrent quotidien
  Future<bool> _createRecurringEvent({
    required Calendar calendar,
    required int planId,
    required int slotIndex,
    required String planName,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = DateTime.now();
      final eventDateTime = DateTime(now.year, now.month, now.day, hour, minute);

      // Si l'heure est déjà passée aujourd'hui, commencer demain
      final startDate = eventDateTime.isBefore(now)
          ? eventDateTime.add(const Duration(days: 1))
          : eventDateTime;

      final event = Event(
        calendar.id,
        eventId: '$EVENT_PREFIX${planId}_$slotIndex',
        title: '🙏 $planName',
        description: 'Rappel pour votre plan de vie Oremus\nHeure: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
        start: TZDateTime.from(startDate, local),
        end: TZDateTime.from(startDate.add(const Duration(minutes: 30)), local),
        allDay: false,
        recurrenceRule: RecurrenceRule(
          RecurrenceFrequency.Daily,
          interval: 1,
        ),
        reminders: [
          Reminder(minutes: 5), // Rappel 5 minutes avant
          Reminder(minutes: 0),  // Rappel à l'heure
        ],
      );

      final result = await _calendar.createOrUpdateEvent(event);
      return result?.isSuccess ?? false;
    } catch (e) {
      log('Erreur création événement récurrent: $e');
      return false;
    }
  }

  /// Supprime tous les événements d'un plan de vie
  Future<bool> removeLifePlanFromCalendar(int planId) async {
    try {
      if (!await requestCalendarPermission()) return false;

      final calendar = await _getOrCreateOremusCalendar();
      if (calendar == null) return false;

      // Récupérer tous les événements Oremus
      final eventsResult = await _calendar.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      if (!eventsResult.isSuccess) return false;

      final events = eventsResult.data ?? [];
      bool allDeleted = true;

      // Supprimer les événements de ce plan
      for (final event in events) {
        if (event.eventId?.startsWith('$EVENT_PREFIX$planId') == true) {
          final result = await _calendar.deleteEvent(calendar.id, event.eventId!);
          if (!(result.isSuccess ?? false)) {
            allDeleted = false;
          }
        }
      }

      return allDeleted;
    } catch (e) {
      log('Erreur suppression événements: $e');
      return false;
    }
  }

  /// Met à jour les créneaux d'un plan de vie dans le calendrier
  Future<bool> updateLifePlanInCalendar(UserLifePlan userLifePlan) async {
    try {
      // Supprimer les anciens événements
      await removeLifePlanFromCalendar(userLifePlan.identifier ?? 0);

      // Ajouter les nouveaux
      return await addLifePlanToCalendar(userLifePlan);
    } catch (e) {
      log('Erreur mise à jour plan dans calendrier: $e');
      return false;
    }
  }

  /// Vérifie si les événements d'un plan existent déjà
  Future<bool> hasLifePlanInCalendar(int planId) async {
    try {
      if (!await requestCalendarPermission()) return false;

      final calendar = await _getOrCreateOremusCalendar();
      if (calendar == null) return false;

      final eventsResult = await _calendar.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        ),
      );

      if (!eventsResult.isSuccess) return false;

      final events = eventsResult.data ?? [];
      return events.any((event) =>
      event.eventId?.startsWith('$EVENT_PREFIX$planId') == true
      );
    } catch (e) {
      log('Erreur vérification événements: $e');
      return false;
    }
  }
}

// Extension pour firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
