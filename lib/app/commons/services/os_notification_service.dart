import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oremusapp/app/commons/components/notifications/notification_popup.dart';
import 'package:oremusapp/app/commons/services/notification_queue_service.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin.dart';
import 'package:oremusapp/app/modules/signin/data/repository/signin_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/main.dart';

class OSNotificationService {
  // Singleton pattern
  static final OSNotificationService _instance = OSNotificationService._internal();
  factory OSNotificationService() => _instance;
  OSNotificationService._internal();

  // Service de file d'attente de notifications
  final NotificationQueueService _queueService = NotificationQueueService();

  // Observable values
  final ValueNotifier<bool> isRedirectNotification = ValueNotifier<bool>(false);
  final ValueNotifier<Map<String, dynamic>?> notificationData = ValueNotifier<Map<String, dynamic>?>(null);

  // Device ID related
  final ValueNotifier<String?> deviceId = ValueNotifier<String?>(null);

  // Protection contre les doubles clics/événements
  String? _lastProcessedNotificationId;
  DateTime? _lastProcessedTime;

  // Initialize OneSignal
  Future<void> initializeOneSignal(String appId) async {
    // Enable debug logging for development
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal
    OneSignal.initialize(appId);

    // Request permission to display notifications
    OneSignal.Notifications.requestPermission(true);

    // Set notification handlers
    setNotificationHandlers();

    // Get and store device ID
    await getDeviceId();
    log("OneSignal initialized with app ID: $appId");
  }

  // Get the device ID from OneSignal
  Future<String?> getDeviceId() async {
    try {
      // Get the player/device ID from the device state
      final deviceState = OneSignal.User.pushSubscription;
      final id = deviceState.id;

      // Store it in our ValueNotifier for easy access
      deviceId.value = id;

      log("OneSignal device ID: $id");
      return id;
    } catch (e) {
      log("Error getting device ID: $e");
      return null;
    }
  }

  // Set up all notification handlers
  void setNotificationHandlers() {
    // When a notification is received while the app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      log("📱 Notification received in foreground: ${event.notification.notificationId}");
      log("📱 Additional data: ${event.notification.additionalData}");

      // Ajouter automatiquement les notifications reçues en premier plan à la file d'attente
      // si elles contiennent des données à afficher
      if (event.notification.additionalData != null &&
          event.notification.additionalData!.isNotEmpty) {
        log("📱 Ajout de la notification foreground à la file d'attente");
        _queueService.enqueueNotification(event.notification);
      }

      // Empêcher l'affichage automatique de la notification système
      event.preventDefault();
    });

    // When a notification is opened
    OneSignal.Notifications.addClickListener((event) {
      final notificationId = event.notification.notificationId;
      final now = DateTime.now();

      log("🔔 Notification opened: $notificationId");
      log("🔔 Additional data: ${event.notification.additionalData}");

      // Protection contre les doubles événements
      if (_lastProcessedNotificationId == notificationId &&
          _lastProcessedTime != null &&
          now.difference(_lastProcessedTime!).inMilliseconds < 2000) {
        log("🚫 Double événement de notification détecté et ignoré: $notificationId");
        return;
      }

      // Marquer cet événement comme traité
      _lastProcessedNotificationId = notificationId;
      _lastProcessedTime = now;

      // Marquer qu'il s'agit d'une notification de redirection
      isRedirectNotification.value = true;
      notificationData.value = event.notification.additionalData;

      log("🔔 isRedirect: ${isRedirectNotification.value}");
      log("🔔 Notification data: ${notificationData.value}");

      // Ajouter la notification à la file d'attente SEULEMENT si elle a des données à afficher
      if (event.notification.additionalData != null &&
          event.notification.additionalData!.isNotEmpty) {
        log("🔔 Ajout de la notification cliquée à la file d'attente");
        _queueService.enqueueNotification(event.notification);
      } else {
        log("⚠️ Notification sans données additionnelles, pas d'ajout à la file");
        // Réinitialiser le flag si pas de données à traiter
        resetRedirectFlag();
      }
    });

    // When permission changes
    OneSignal.Notifications.addPermissionObserver((stateChanges) {
      log("🔐 Permission changed: ${stateChanges.toString()}");
    });

    // When subscription status changes
    OneSignal.User.addObserver((event) {
      log("📊 Push subscription state changed: ${event.current.jsonRepresentation()}");

      // Device ID might change when subscription status changes, so update it
      getDeviceId();
    });
  }

  // Reset redirection flag (call this after navigation is complete)
  void resetRedirectFlag() {
    log("🔄 Réinitialisation du flag de redirection");
    isRedirectNotification.value = false;
    notificationData.value = null;
  }

  // Set external user ID for targeting
  Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      log("👤 External user ID set: $userId");
    } catch (e) {
      log("❌ Error setting external user ID: $e");
    }
  }

  // Use device ID during login process
  Future<Map<String, String?>> getDeviceInfoForLogin() async {
    // Make sure we have the latest device ID
    await getDeviceId();

    return {
      'device_id': deviceId.value,
      'device_type': 'mobile', // You could enhance this with platform-specific info
    };
  }

  // Set user tags for segmentation
  Future<void> setUserTags(Map<String, dynamic> tags) async {
    try {
      OneSignal.User.addTags(tags);
      log("🏷️ User tags set: $tags");
    } catch (e) {
      log("❌ Error setting user tags: $e");
    }
  }

  // Log out user
  Future<void> logoutUser() async {
    try {
      await OneSignal.logout();
      log("👋 User logged out from OneSignal");

      // Vider la file d'attente des notifications lors de la déconnexion
      _queueService.clearQueue();

      // Réinitialiser les flags
      resetRedirectFlag();

      // Réinitialiser les protections contre les doubles événements
      _lastProcessedNotificationId = null;
      _lastProcessedTime = null;

      // Device ID might change after logout, so update it
      await getDeviceId();
    } catch (e) {
      log("❌ Error logging out user: $e");
    }
  }

  // Méthode pour obtenir le nombre de notifications en attente
  int get pendingNotificationsCount => _queueService.queueSize;

  // Méthode pour vérifier si une notification est actuellement affichée
  bool get isDisplayingNotification => _queueService.isDisplayingNotification;

  // Méthode pour obtenir l'état de traitement de la file d'attente
  bool get isProcessingQueue => _queueService.isProcessingQueue;

  // Méthode pour forcer le nettoyage de la file d'attente
  void clearNotificationQueue() {
    log("🗑️ Nettoyage forcé de la file d'attente de notifications");
    _queueService.clearQueue();
    resetRedirectFlag();
  }

  // Méthode pour ajouter manuellement une notification à la file d'attente
  void addNotificationToQueue(OSNotification notification) {
    log("➕ Ajout manuel d'une notification à la file d'attente");
    _queueService.enqueueNotification(notification);
  }

  // Méthode pour obtenir des informations de debug sur la file d'attente
  void debugNotificationQueue() {
    _queueService.debugPrintStatus();
  }

  // Méthode pour forcer la fermeture de la notification actuelle
  void forceCloseCurrentNotification() {
    log("🚨 Fermeture forcée de la notification actuelle");
    _queueService.forceCompleteCurrentNotification();
  }

  // Méthode pour réinitialiser les protections contre les doubles événements
  void resetDuplicateProtection() {
    log("🔄 Réinitialisation des protections contre les doubles événements");
    _lastProcessedNotificationId = null;
    _lastProcessedTime = null;
  }

  // Méthode pour supprimer manuellement un ID de notification traité
  void removeProcessedNotificationId(String notificationId) {
    _queueService.removeProcessedNotificationId(notificationId);
  }
}
