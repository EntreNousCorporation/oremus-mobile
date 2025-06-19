import 'dart:async';
import 'dart:developer';
import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal() {
    // Initialiser les données de timezone
    tz.initializeTimeZones();
  }

  /// Obtient la timezone locale
  tz.Location _getLocalTimeZone() {
    try {
      // Essayer d'obtenir la timezone locale
      return tz.local;
    } catch (e) {
      log('⚠️ Erreur timezone locale, utilisation UTC: $e');
      // Fallback vers UTC si problème
      return tz.UTC;
    }
  }

  DeviceCalendarPlugin? _deviceCalendarPlugin;
  Calendar? _defaultCalendar;

  static const String EVENT_PREFIX = "OREMUS_LIFEPLAN_";

  DeviceCalendarPlugin get _calendar {
    _deviceCalendarPlugin ??= DeviceCalendarPlugin();
    return _deviceCalendarPlugin!;
  }

  /// Vérifie et demande les permissions calendrier
  Future<bool> requestCalendarPermission() async {
    try {
      log('🔍 Vérification des permissions calendrier...');

      var permissionsGranted = await _calendar.hasPermissions();
      log('📋 Permissions actuelles: ${permissionsGranted.data}');

      if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
        log('✅ Permissions déjà accordées');
        return true;
      }

      log('🔐 Demande de permissions...');
      permissionsGranted = await _calendar.requestPermissions();
      final granted = permissionsGranted.isSuccess && (permissionsGranted.data ?? false);

      log('🎯 Résultat permissions: $granted');
      return granted;
    } catch (e) {
      log('❌ Erreur permissions calendrier: $e');
      return false;
    }
  }

  /// Trouve le calendrier par défaut ou le premier calendrier disponible
  Future<Calendar?> _getDefaultCalendar() async {
    if (_defaultCalendar != null) {
      log('📅 Utilisation du calendrier en cache: ${_defaultCalendar!.name}');
      return _defaultCalendar;
    }

    try {
      log('🔍 Recherche des calendriers disponibles...');
      final calendarsResult = await _calendar.retrieveCalendars();

      if (!calendarsResult.isSuccess) {
        log('❌ Échec récupération calendriers: ${calendarsResult.errors}');
        return null;
      }

      final calendars = calendarsResult.data ?? [];
      log('📋 ${calendars.length} calendriers trouvés');

      if (calendars.isEmpty) {
        log('❌ Aucun calendrier disponible');
        return null;
      }

      // Chercher le calendrier par défaut en premier
      _defaultCalendar = calendars.firstWhereOrNull(
              (cal) => cal.isDefault == true && cal.isReadOnly == false
      );

      // Si pas de calendrier par défaut, prendre le premier modifiable
      _defaultCalendar ??= calendars.firstWhereOrNull(
              (cal) => cal.isReadOnly == false
      );

      // En dernier recours, prendre le premier disponible
      _defaultCalendar ??= calendars.first;

      log('✅ Calendrier sélectionné: ${_defaultCalendar!.name} (ID: ${_defaultCalendar!.id})');
      log('📝 Propriétés: isDefault=${_defaultCalendar!.isDefault}, isReadOnly=${_defaultCalendar!.isReadOnly}');

      return _defaultCalendar;
    } catch (e) {
      log('❌ Erreur récupération calendrier: $e');
      return null;
    }
  }

  /// Ajoute les créneaux d'un plan de vie au calendrier
  Future<bool> addLifePlanToCalendar(UserLifePlan userLifePlan) async {
    try {
      log('🚀 Début ajout plan de vie au calendrier...');

      if (!await requestCalendarPermission()) {
        log('❌ Permissions calendrier refusées');
        return false;
      }

      final calendar = await _getDefaultCalendar();
      if (calendar == null) {
        log('❌ Impossible de récupérer le calendrier');
        return false;
      }

      final planName = userLifePlan.lifePlan?.name?.fr ?? 'Plan de vie';
      final slots = userLifePlan.slots ?? [];
      final planId = userLifePlan.identifier ?? 0;

      log('📋 Plan: $planName (ID: $planId)');
      log('⏰ ${slots.length} créneaux à ajouter');

      if (slots.isEmpty) {
        log('⚠️ Aucun créneau à ajouter');
        return true;
      }

      int successCount = 0;

      for (int i = 0; i < slots.length; i++) {
        final slot = slots[i];
        if (slot.hour == null || slot.minute == null) {
          log('⚠️ Créneau $i invalide: ${slot.getFormattedTime()}');
          continue;
        }

        log('📅 Création événement ${i + 1}/${slots.length}: ${slot.getFormattedTime()}');

        final success = await _createRecurringEvent(
          calendar: calendar,
          planId: planId,
          slotIndex: i,
          planName: planName,
          hour: slot.hour!,
          minute: slot.minute!,
        );

        if (success) {
          successCount++;
          log('✅ Événement créé: ${slot.getFormattedTime()}');
        } else {
          log('❌ Échec création événement: ${slot.getFormattedTime()}');
        }
      }

      final allSuccess = successCount == slots.length;
      log('🎯 Résultat: $successCount/${slots.length} événements créés avec succès');

      return allSuccess;
    } catch (e) {
      log('❌ Erreur ajout plan au calendrier: $e');
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

      // Convertir en TZDateTime avec la timezone locale
      final localTz = _getLocalTimeZone();
      final tzStartDate = tz.TZDateTime.from(startDate, localTz);
      final tzEndDate = tz.TZDateTime.from(startDate.add(const Duration(minutes: 15)), localTz);

      final eventId = '$EVENT_PREFIX${planId}_$slotIndex';

      log('🔧 Création événement:');
      log('   - ID: $eventId');
      log('   - Titre: 🙏 $planName');
      log('   - Heure: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      log('   - Date début: $tzStartDate');

      final event = Event(
        calendar.id,
        eventId: eventId,
        title: '🙏 $planName',
        description: 'Rappel pour votre plan de vie Oremus\n'
            'Heure: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}\n'
            'Plan ID: $planId',
        start: tzStartDate,
        end: tzEndDate,
        allDay: false,
        recurrenceRule: RecurrenceRule(
          RecurrenceFrequency.Daily,
          interval: 1,
        ),
        reminders: [
          Reminder(minutes: 0),  // Rappel à l'heure
        ],
      );

      log('📤 Envoi de l\'événement au calendrier...');
      final result = await _calendar.createOrUpdateEvent(event);

      log('📨 Résultat création: success=${result?.isSuccess}, data=${result?.data}');
      if (result?.errors.isNotEmpty == true) {
        log('⚠️ Erreurs: ${result!.errors}');
      }

      final success = result?.isSuccess ?? false;

      if (success) {
        log('✅ Événement créé avec succès dans le calendrier');

        // Vérification supplémentaire : essayer de récupérer l'événement
        await _verifyEventCreation(calendar.id!, eventId);
      } else {
        log('❌ Échec création événement');
      }

      return success;
    } catch (e) {
      log('❌ Erreur création événement récurrent: $e');
      return false;
    }
  }

  /// Vérifie qu'un événement a bien été créé
  Future<void> _verifyEventCreation(String calendarId, String eventId) async {
    try {
      log('🔍 Vérification de l\'événement créé...');

      final eventsResult = await _calendar.retrieveEvents(
        calendarId,
        RetrieveEventsParams(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        ),
      );

      if (eventsResult.isSuccess) {
        final events = eventsResult.data ?? [];
        final foundEvent = events.firstWhereOrNull(
                (event) => event.eventId == eventId
        );

        if (foundEvent != null) {
          log('✅ Événement vérifié dans le calendrier: ${foundEvent.title}');
        } else {
          log('⚠️ Événement non trouvé lors de la vérification');
          log('📋 ${events.length} événements trouvés dans la période');
        }
      } else {
        log('❌ Échec vérification événements');
      }
    } catch (e) {
      log('⚠️ Erreur vérification événement: $e');
    }
  }

  /// Supprime tous les événements d'un plan de vie
  Future<bool> removeLifePlanFromCalendar(int planId) async {
    try {
      log('🗑️ Suppression des événements du plan $planId...');

      if (!await requestCalendarPermission()) {
        log('❌ Permissions calendrier refusées');
        return false;
      }

      final calendar = await _getDefaultCalendar();
      if (calendar == null) {
        log('❌ Impossible de récupérer le calendrier');
        return false;
      }

      // Récupérer tous les événements sur une période étendue
      final eventsResult = await _calendar.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );

      if (!eventsResult.isSuccess) {
        log('❌ Échec récupération événements: ${eventsResult.errors}');
        return false;
      }

      final events = eventsResult.data ?? [];
      final eventsToDelete = events.where(
              (event) => event.eventId?.startsWith('$EVENT_PREFIX$planId') == true
      ).toList();

      log('📋 ${eventsToDelete.length} événements à supprimer');

      if (eventsToDelete.isEmpty) {
        log('ℹ️ Aucun événement trouvé pour ce plan');
        return true;
      }

      int deletedCount = 0;

      for (final event in eventsToDelete) {
        log('🗑️ Suppression: ${event.eventId}');
        final result = await _calendar.deleteEvent(calendar.id!, event.eventId!);

        if (result.isSuccess ?? false) {
          deletedCount++;
          log('✅ Événement supprimé: ${event.eventId}');
        } else {
          log('❌ Échec suppression: ${event.eventId} - ${result.errors}');
        }
      }

      log('🎯 $deletedCount/${eventsToDelete.length} événements supprimés');
      return deletedCount == eventsToDelete.length;
    } catch (e) {
      log('❌ Erreur suppression événements: $e');
      return false;
    }
  }

  /// Met à jour les créneaux d'un plan de vie dans le calendrier
  Future<bool> updateLifePlanInCalendar(UserLifePlan userLifePlan) async {
    try {
      log('🔄 Mise à jour du plan ${userLifePlan.identifier} dans le calendrier...');

      // Supprimer les anciens événements
      final deleted = await removeLifePlanFromCalendar(userLifePlan.identifier ?? 0);
      if (!deleted) {
        log('⚠️ Problème lors de la suppression des anciens événements');
      }

      // Ajouter les nouveaux
      final added = await addLifePlanToCalendar(userLifePlan);

      log('🎯 Résultat mise à jour: ${added ? 'succès' : 'échec'}');
      return added;
    } catch (e) {
      log('❌ Erreur mise à jour plan dans calendrier: $e');
      return false;
    }
  }

  /// Vérifie si les événements d'un plan existent déjà
  Future<bool> hasLifePlanInCalendar(int planId) async {
    try {
      log('🔍 Vérification présence du plan $planId dans le calendrier...');

      if (!await requestCalendarPermission()) return false;

      final calendar = await _getDefaultCalendar();
      if (calendar == null) return false;

      final eventsResult = await _calendar.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
        ),
      );

      if (!eventsResult.isSuccess) return false;

      final events = eventsResult.data ?? [];
      final hasEvents = events.any((event) =>
      event.eventId?.startsWith('$EVENT_PREFIX$planId') == true
      );

      log('📋 Plan $planId ${hasEvents ? 'trouvé' : 'non trouvé'} dans le calendrier');
      return hasEvents;
    } catch (e) {
      log('❌ Erreur vérification événements: $e');
      return false;
    }
  }

  /// Méthode de test pour créer un événement simple
  Future<bool> createTestEvent() async {
    try {
      log('🧪 Test de création d\'événement...');

      if (!await requestCalendarPermission()) {
        log('❌ Pas de permissions');
        return false;
      }

      final calendar = await _getDefaultCalendar();
      if (calendar == null) {
        log('❌ Pas de calendrier');
        return false;
      }

      final now = DateTime.now();
      final testTime = now.add(const Duration(minutes: 5));

      // Convertir en TZDateTime avec la timezone locale
      final localTz = _getLocalTimeZone();
      final tzStartTime = tz.TZDateTime.from(testTime, localTz);
      final tzEndTime = tz.TZDateTime.from(testTime.add(const Duration(minutes: 15)), localTz);

      final event = Event(
        calendar.id,
        title: 'Test Oremus 🙏',
        description: 'Événement de test pour vérifier le fonctionnement',
        start: tzStartTime,
        end: tzEndTime,
        allDay: false,
      );

      final result = await _calendar.createOrUpdateEvent(event);
      final success = result?.isSuccess ?? false;

      log('🎯 Test événement: ${success ? 'succès' : 'échec'}');
      if (!success) {
        log('❌ Erreurs: ${result?.errors}');
      }

      return success;
    } catch (e) {
      log('❌ Erreur test événement: $e');
      return false;
    }
  }

  /// Nettoyage rapide des événements Oremus (pour déblocage d'urgence)
  Future<bool> quickCleanupOremusEvents() async {
    try {
      log('🧹 Nettoyage rapide des événements Oremus...');

      if (!await requestCalendarPermission()) {
        return false;
      }

      final calendar = await _getDefaultCalendar();
      if (calendar == null) {
        return false;
      }

      // Recherche sur une période très courte
      final eventsResult = await _calendar.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 7)),
        ),
      ).timeout(const Duration(seconds: 5));

      if (!eventsResult.isSuccess) {
        return false;
      }

      final events = eventsResult.data ?? [];
      final oremusEvents = events.where(
              (event) => event.eventId?.startsWith(EVENT_PREFIX) == true
      ).take(10).toList(); // Limiter à 10 événements max

      log('🧹 Suppression rapide de ${oremusEvents.length} événements Oremus');

      for (final event in oremusEvents) {
        try {
          await _calendar.deleteEvent(calendar.id!, event.eventId!).timeout(
            const Duration(seconds: 2),
          );
        } catch (e) {
          // Ignorer les erreurs individuelles
        }
      }

      return true;
    } catch (e) {
      log('❌ Erreur nettoyage rapide: $e');
      return false;
    }
  }
  Future<void> debugListCalendars() async {
    try {
      log('🔍 === DEBUG: Liste des calendriers ===');

      final calendarsResult = await _calendar.retrieveCalendars();
      if (!calendarsResult.isSuccess) {
        log('❌ Échec récupération calendriers');
        return;
      }

      final calendars = calendarsResult.data ?? [];
      log('📋 ${calendars.length} calendriers trouvés:');

      for (int i = 0; i < calendars.length; i++) {
        final cal = calendars[i];
        log('  $i. ${cal.name}');
        log('     - ID: ${cal.id}');
        log('     - isDefault: ${cal.isDefault}');
        log('     - isReadOnly: ${cal.isReadOnly}');
        log('     - accountName: ${cal.accountName}');
        log('     - accountType: ${cal.accountType}');
      }
    } catch (e) {
      log('❌ Erreur debug calendriers: $e');
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