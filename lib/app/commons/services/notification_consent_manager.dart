import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:oremusapp/app/commons/services/os_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationConsentManager {
  static const String _prefNotificationConsent = 'notification_consent';
  static const String _prefLastPromptDate = 'last_notification_prompt_date';

  // Singleton pattern
  static final NotificationConsentManager _instance = NotificationConsentManager._internal();
  factory NotificationConsentManager() => _instance;
  NotificationConsentManager._internal();

  /// Vérifie si l'utilisateur a déjà été invité à activer les notifications
  Future<bool> hasPromptedForConsent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_prefNotificationConsent);
  }

  /// Vérifie si l'utilisateur a déjà accepté les notifications
  Future<bool> hasUserConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefNotificationConsent) ?? false;
  }

  /// Sauvegarde la décision de l'utilisateur concernant les notifications
  Future<void> saveUserConsent(bool consent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefNotificationConsent, consent);
    await prefs.setInt(_prefLastPromptDate, DateTime.now().millisecondsSinceEpoch);
  }

  /// Vérifie si nous pouvons à nouveau proposer les notifications
  /// (attendre au moins 3 jours depuis la dernière demande)
  Future<bool> canPromptAgain() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPrompt = prefs.getInt(_prefLastPromptDate);

    if (lastPrompt == null) return true;

    final lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPrompt);
    final now = DateTime.now();
    final difference = now.difference(lastPromptDate).inDays;

    return difference >= 3;
  }

  /// Réinitialise les préférences de consentement
  Future<void> resetConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefNotificationConsent);
    await prefs.remove(_prefLastPromptDate);
  }
}

/// Affiche le dialogue de consentement aux notifications
Future<bool> showNotificationConsentDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _NotificationConsentContent(context),
      );
    },
  );

  // Enregistrement de la décision de l'utilisateur
  if (result != null) {
    await NotificationConsentManager().saveUserConsent(result);

    // Si l'utilisateur a accepté, demander la permission système
    if (result) {
      return await OneSignal.Notifications.requestPermission(true);
    }
  }

  return false;
}

/// Contenu du dialogue de consentement
class _NotificationConsentContent extends StatelessWidget {
  final BuildContext parentContext;

  const _NotificationConsentContent(this.parentContext);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Rejoignez la communauté de prière",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Activez les notifications pour recevoir les intentions de prière quotidiennes et ne manquez jamais un moment de communion spirituelle avec la communauté Oremus.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Plus tard"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "Activer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 45,
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }
}

/// Extension du service de notification existant
extension NotificationConsentExtension on OSNotificationService {
  /// Initialise OneSignal avec gestion du consentement
  Future<void> initializeWithConsent(String appId, BuildContext context) async {
    // Vérifie si l'utilisateur a déjà pris une décision
    final consentManager = NotificationConsentManager();
    final hasConsented = await consentManager.hasUserConsented();
    final hasBeenPrompted = await consentManager.hasPromptedForConsent();
    final canPromptAgain = await consentManager.canPromptAgain();

    // Initialize OneSignal in any case (but don't request permission yet)
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    setNotificationHandlers();
    log("OneSignal initialized with app ID: $appId");

    // Décide si on doit montrer la boîte de dialogue
    if (!hasBeenPrompted || (!hasConsented && canPromptAgain)) {
      final result = await showNotificationConsentDialog(context);
      log("User notification consent result: $result");
    } else if (hasConsented) {
      // Si l'utilisateur a déjà consenti, demande directement la permission
      await OneSignal.Notifications.requestPermission(true);
    }
  }

  /// Vérifie et demande le consentement aux notifications à tout moment
  Future<bool> checkAndRequestConsent(BuildContext context) async {
    final consentManager = NotificationConsentManager();
    final hasConsented = await consentManager.hasUserConsented();

    if (hasConsented) {
      return true;
    } else {
      final result = await showNotificationConsentDialog(context);
      return result;
    }
  }

  /// Désactive les notifications lorsque l'utilisateur le demande
  Future<void> disableNotifications() async {
    final consentManager = NotificationConsentManager();

    // Mettre à jour la préférence utilisateur
    await consentManager.saveUserConsent(false);

    // Désactiver les notifications au niveau OneSignal
    await OneSignal.Notifications.clearAll();
    await OneSignal.Notifications.removeNotification(0);

    // Désactiver les permissions de notification
    await OneSignal.Notifications.requestPermission(false);

    log("Notifications désactivées par l'utilisateur");
  }
}
