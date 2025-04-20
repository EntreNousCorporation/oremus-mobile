import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oremusapp/app/commons/components/notifications/notification_popup.dart';
import 'package:oremusapp/app/commons/services/notification_queue_service.dart'; // Importer le nouveau service

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
      log("Notification received in foreground: ${event.notification.additionalData}");

      // Optionnellement, vous pourriez ajouter la notification à la file d'attente ici aussi
      // si on souhaite afficher automatiquement les notifications reçues en premier plan
      // _queueService.enqueueNotification(event.notification);
    });

    // When a notification is opened
    OneSignal.Notifications.addClickListener((event) {
      isRedirectNotification.value = true;
      notificationData.value = event.notification.additionalData;

      log("Notification opened: ${event.notification.notificationId}");
      log("isRedirect: ${isRedirectNotification.value}");
      log("Notification data: ${notificationData.value}");

      // Ajouter la notification à la file d'attente au lieu de la traiter directement
      if (notificationData.value != null) {
        _queueService.enqueueNotification(event.notification);
      }
    });

    // When permission changes
    OneSignal.Notifications.addPermissionObserver((stateChanges) {
      log("Permission changed from ${stateChanges.toString()}");
    });

    // When subscription status changes
    OneSignal.User.addObserver((event) {
      log("Push subscription state changed: ${event.current.jsonRepresentation()}");

      // Device ID might change when subscription status changes, so update it
      getDeviceId();
    });
  }

  // Cette méthode n'est plus utilisée directement, mais conservée pour référence
  void _handleNotificationNavigation(OSNotification notification) {
    // Extraire les informations de la notification
    final data = notification.additionalData;
    if (data == null) return;

    // Récupérer les informations pour le popup
    String title = notification.title ?? "Notification";
    String contents = data['contents'] ?? notification.body ?? "";
    String? notificationType = data['notificationType'];

    // Vérifier que nous avons un contexte valide
    if (Get.context != null) {
      // Légère temporisation pour permettre à l'application de se stabiliser
      Future.delayed(const Duration(milliseconds: 300), () {
        NotificationPopup.show(
          context: Get.context!,
          title: title,
          contents: contents,
          notificationType: notificationType,
          onDismiss: () {
            log("Notification fermée");
            resetRedirectFlag();
          },
        );
      });
    }

    log("Notification gérée: ${notification.notificationId}");
    log("Données: $data");
  }

  // Reset redirection flag (call this after navigation is complete)
  void resetRedirectFlag() {
    isRedirectNotification.value = false;
    notificationData.value = null;
  }

  // Additional useful methods

  // Set external user ID for targeting
  Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      log("External user ID set: $userId");
    } catch (e) {
      log("Error setting external user ID: $e");
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
      log("User tags set: $tags");
    } catch (e) {
      log("Error setting user tags: $e");
    }
  }

  // Log out user
  Future<void> logoutUser() async {
    try {
      await OneSignal.logout();
      log("User logged out from OneSignal");

      // Vider la file d'attente des notifications lors de la déconnexion
      _queueService.clearQueue();

      // Device ID might change after logout, so update it
      await getDeviceId();
    } catch (e) {
      log("Error logging out user: $e");
    }
  }

  // Méthode pour obtenir le nombre de notifications en attente
  int get pendingNotificationsCount => _queueService.queueSize;
}
