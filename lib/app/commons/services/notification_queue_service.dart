import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oremusapp/app/commons/components/notifications/notification_popup.dart';

class NotificationQueueService {
  // Singleton pattern
  static final NotificationQueueService _instance = NotificationQueueService._internal();
  factory NotificationQueueService() => _instance;
  NotificationQueueService._internal();

  // File d'attente des notifications
  final Queue<OSNotification> _notificationQueue = Queue<OSNotification>();

  // État de traitement de la file d'attente
  bool _isProcessingQueue = false;

  // Flag pour vérifier si une notification est actuellement affichée
  bool _isNotificationCurrentlyDisplayed = false;

  // Contrôleur pour la notification actuellement affichée
  Completer<void>? _currentNotificationCompleter;

  // Set pour tracker les IDs des notifications déjà traitées
  final Set<String> _processedNotificationIds = <String>{};

  // TODO: implémenter un cleanup périodique de _processedNotificationIds
  // basé sur cette durée pour éviter le memory leak.
  // ignore: unused_field
  static const Duration _idRetentionDuration = Duration(hours: 24);

  // Ajoute une notification à la file d'attente et démarre le traitement si nécessaire
  void enqueueNotification(OSNotification notification) {
    final notificationId = notification.notificationId;

    // Vérifier si cette notification a déjà été traitée
    if (_processedNotificationIds.contains(notificationId)) {
      log("🚫 Notification dupliquée détectée et ignorée: $notificationId");
      return;
    }

    log("📱 Notification ajoutée à la file d'attente: $notificationId");
    log("📊 Taille actuelle de la file d'attente: ${_notificationQueue.length}");
    log("🔄 En cours de traitement: $_isProcessingQueue");
    log("👁️ Notification affichée: $_isNotificationCurrentlyDisplayed");

    // Marquer cette notification comme en cours de traitement
    _processedNotificationIds.add(notificationId);
    log("✅ ID ajouté aux notifications traitées: $notificationId");

    // Nettoyer les anciens IDs périodiquement (éviter memory leak)
    _cleanupOldNotificationIds();

    // Ajouter la notification à la file d'attente
    _notificationQueue.add(notification);

    // Démarrer le traitement de la file d'attente si ce n'est pas déjà en cours
    if (!_isProcessingQueue) {
      _processQueue();
    }
  }

  // Traite la file d'attente des notifications
  Future<void> _processQueue() async {
    if (_notificationQueue.isEmpty) {
      log("📭 File d'attente vide, arrêt du traitement");
      return;
    }

    if (_isProcessingQueue) {
      log("⚠️ Traitement déjà en cours, retour anticipé");
      return;
    }

    log("🚀 Début du traitement de la file d'attente");
    _isProcessingQueue = true;

    try {
      while (_notificationQueue.isNotEmpty) {
        final notification = _notificationQueue.removeFirst();
        log("📤 Traitement de la notification: ${notification.notificationId}");
        log("📊 Notifications restantes dans la file: ${_notificationQueue.length}");

        // Vérifier qu'aucune notification n'est déjà affichée
        if (_isNotificationCurrentlyDisplayed) {
          log("⏳ Une notification est déjà affichée, attente...");
          // Remettre la notification au début de la file
          _notificationQueue.addFirst(notification);
          // Attendre un peu avant de réessayer
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }

        // Marquer qu'une notification est en cours d'affichage
        _isNotificationCurrentlyDisplayed = true;

        // Créer un nouveau completer pour cette notification
        _currentNotificationCompleter = Completer<void>();

        // Afficher la notification
        await _displayNotificationPopup(notification);

        // Attendre que l'utilisateur ferme la notification
        if (_currentNotificationCompleter != null && !_currentNotificationCompleter!.isCompleted) {
          log("⏳ Attente de la fermeture de la notification...");
          await _currentNotificationCompleter!.future;
        }

        // Marquer que la notification n'est plus affichée
        _isNotificationCurrentlyDisplayed = false;

        log("✅ Notification ${notification.notificationId} traitée et fermée");

        // Petite pause entre chaque notification pour une meilleure expérience
        if (_notificationQueue.isNotEmpty) {
          log("⏸️ Pause entre les notifications...");
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      log("❌ Erreur lors du traitement de la file d'attente: $e");
      _isNotificationCurrentlyDisplayed = false;
    } finally {
      _isProcessingQueue = false;
      log("🏁 Fin du traitement de la file d'attente");
    }
  }

  // Affiche le popup de notification
  Future<void> _displayNotificationPopup(OSNotification notification) async {
    // Extraire les informations de la notification
    final data = notification.additionalData;
    if (data == null) {
      log("⚠️ Pas de données additionnelles dans la notification");
      _completeCurrentNotification();
      return;
    }

    // Récupérer les informations pour le popup
    String title = notification.title ?? "Notification";
    String contents = data['contents'] ?? notification.body ?? "";
    String? notificationType = data['notificationType'];

    log("📝 Affichage du popup - Titre: $title, Type: $notificationType");

    // Vérifier que nous avons un contexte valide
    if (Get.context == null) {
      log("❌ Pas de contexte disponible pour afficher la notification");
      _completeCurrentNotification();
      return;
    }

    try {
      // Légère temporisation pour permettre à l'application de se stabiliser
      await Future.delayed(const Duration(milliseconds: 300));

      // Vérifier à nouveau le contexte après le délai
      if (Get.context == null) {
        log("❌ Contexte perdu après le délai");
        _completeCurrentNotification();
        return;
      }

      log("🎯 Affichage du popup de notification");

      await NotificationPopup.show(
        context: Get.context!,
        title: title,
        contents: contents,
        notificationType: notificationType,
        onDismiss: () {
          log("🔻 Notification fermée par l'utilisateur");
          _completeCurrentNotification();
        },
      );
    } catch (e) {
      log("❌ Erreur lors de l'affichage du popup: $e");
      _completeCurrentNotification();
    }
  }

  // Marque la notification actuelle comme complétée et passe à la suivante
  void _completeCurrentNotification() {
    log("✅ Marquage de la notification actuelle comme complétée");

    if (_currentNotificationCompleter != null && !_currentNotificationCompleter!.isCompleted) {
      _currentNotificationCompleter!.complete();
      log("🏁 Completer marqué comme terminé");
    } else {
      log("⚠️ Completer déjà terminé ou null");
    }

    // S'assurer que le flag est réinitialisé
    _isNotificationCurrentlyDisplayed = false;
  }

  // Force la fermeture de la notification actuelle (utile pour les cas d'urgence)
  void forceCompleteCurrentNotification() {
    log("🚨 Forçage de la fermeture de la notification actuelle");
    _isNotificationCurrentlyDisplayed = false;
    _completeCurrentNotification();
  }

  // Vide la file d'attente
  void clearQueue() {
    log("🗑️ Vidage de la file d'attente (${_notificationQueue.length} notifications supprimées)");
    _notificationQueue.clear();

    // Nettoyer aussi les IDs des notifications traitées
    _processedNotificationIds.clear();
    log("🗑️ IDs des notifications traitées supprimés");

    // Forcer la completion de la notification actuelle si elle existe
    if (_isNotificationCurrentlyDisplayed) {
      forceCompleteCurrentNotification();
    }

    _isProcessingQueue = false;
  }

  // Nettoie les anciens IDs de notifications (simple version basée sur la taille)
  void _cleanupOldNotificationIds() {
    // Garder seulement les 50 derniers IDs pour éviter un memory leak
    // Dans un vrai projet, on pourrait stocker avec timestamp pour un nettoyage basé sur le temps
    if (_processedNotificationIds.length > 50) {
      final idsToRemove = _processedNotificationIds.length - 50;
      final idsToDelete = _processedNotificationIds.take(idsToRemove).toList();

      for (final id in idsToDelete) {
        _processedNotificationIds.remove(id);
      }

      log("🧹 Nettoyage de ${idsToDelete.length} anciens IDs de notifications");
    }
  }

  // Méthode pour forcer la suppression d'un ID spécifique (utile pour les tests)
  void removeProcessedNotificationId(String notificationId) {
    if (_processedNotificationIds.remove(notificationId)) {
      log("🗑️ ID de notification supprimé manuellement: $notificationId");
    }
  }

  // Renvoie la taille actuelle de la file d'attente
  int get queueSize => _notificationQueue.length;

  // Indique si une notification est actuellement affichée
  bool get isDisplayingNotification => _isNotificationCurrentlyDisplayed;

  // Indique si la file d'attente est en cours de traitement
  bool get isProcessingQueue => _isProcessingQueue;

  // Méthode de debug pour afficher l'état actuel
  void debugPrintStatus() {
    log("📊 === ÉTAT DE LA FILE D'ATTENTE ===");
    log("📊 Taille de la file: ${_notificationQueue.length}");
    log("📊 En cours de traitement: $_isProcessingQueue");
    log("📊 Notification affichée: $_isNotificationCurrentlyDisplayed");
    log("📊 Completer actuel: ${_currentNotificationCompleter != null ? 'Existe' : 'Null'}");
    if (_currentNotificationCompleter != null) {
      log("📊 Completer terminé: ${_currentNotificationCompleter!.isCompleted}");
    }
    log("📊 IDs traités en mémoire: ${_processedNotificationIds.length}");
    if (_processedNotificationIds.isNotEmpty) {
      log("📊 Derniers IDs traités: ${_processedNotificationIds.take(5).join(', ')}");
    }
    log("📊 ================================");
  }
}
