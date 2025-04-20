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

  // Contrôleur pour la notification actuellement affichée
  Completer<void>? _currentNotificationCompleter;

  // Ajoute une notification à la file d'attente et démarre le traitement si nécessaire
  void enqueueNotification(OSNotification notification) {
    log("Notification ajoutée à la file d'attente: ${notification.notificationId}");

    // Ajouter la notification à la file d'attente
    _notificationQueue.add(notification);

    // Démarrer le traitement de la file d'attente si ce n'est pas déjà en cours
    if (!_isProcessingQueue) {
      _processQueue();
    }
  }

  // Traite la file d'attente des notifications
  Future<void> _processQueue() async {
    if (_notificationQueue.isEmpty || _isProcessingQueue) {
      return;
    }

    _isProcessingQueue = true;

    while (_notificationQueue.isNotEmpty) {
      final notification = _notificationQueue.removeFirst();
      log("Traitement de la notification: ${notification.notificationId}");

      // Créer un nouveau completer pour cette notification
      _currentNotificationCompleter = Completer<void>();

      // Afficher la notification
      _displayNotificationPopup(notification);

      // Attendre que l'utilisateur ferme la notification
      await _currentNotificationCompleter!.future;

      // Petite pause entre chaque notification pour une meilleure expérience
      if (_notificationQueue.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    _isProcessingQueue = false;
  }

  // Affiche le popup de notification
  void _displayNotificationPopup(OSNotification notification) {
    // Extraire les informations de la notification
    final data = notification.additionalData;
    if (data == null) {
      _completeCurrentNotification();
      return;
    }

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
            _completeCurrentNotification();
          },
        );
      });
    } else {
      // Si pas de contexte, marquer comme complétée
      _completeCurrentNotification();
    }
  }

  // Marque la notification actuelle comme complétée et passe à la suivante
  void _completeCurrentNotification() {
    if (_currentNotificationCompleter != null && !_currentNotificationCompleter!.isCompleted) {
      _currentNotificationCompleter!.complete();
    }
  }

  // Vide la file d'attente
  void clearQueue() {
    _notificationQueue.clear();
  }

  // Renvoie la taille actuelle de la file d'attente
  int get queueSize => _notificationQueue.length;
}
