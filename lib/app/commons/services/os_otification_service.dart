import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OSNotificationService {
  // Singleton pattern
  static final OSNotificationService _instance = OSNotificationService._internal();
  factory OSNotificationService() => _instance;
  OSNotificationService._internal();

  // Observable values
  final ValueNotifier<bool> isRedirectNotification = ValueNotifier<bool>(false);
  final ValueNotifier<Map<String, dynamic>?> notificationData = ValueNotifier<Map<String, dynamic>?>(null);

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

    log("OneSignal initialized with app ID: $appId");
    _handleSendTags();
  }

  void _handleSendTags() {
    // Sending a single tag
    try {
      // In v5.3.0, tags are added using OneSignal.User.addTag or addTags
      OneSignal.User.addTagWithKey("category", "pdv");
      log("Successfully sent category tag");
    } catch (e) {
      log("Encountered an error sending single tag: $e");
    }

    // Sending multiple tags
    try {
      // For multiple tags, use a Map and the addTags method
      Map<String, String> tags = {
        'category': 'pdv',
        'test': 'value',
        'user_type': 'customer'
      };

      OneSignal.User.addTags(tags);
      log("Successfully sent multiple tags");
    } catch (e) {
      log("Encountered an error sending multiple tags: $e");
    }
  }

  // Set up all notification handlers
  void setNotificationHandlers() {
    // When a notification is received while the app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      log("Notification received in foreground: ${event.notification.additionalData}");

      // You can prevent notification from displaying
      // event.preventDefault();

      // Or modify it before display
      // event.notification.additionalData?['custom_key'] = 'modified_value';

      // Complete the event to display the notification
      //event.complete(event.notification);
    });

    // When a notification is opened
    OneSignal.Notifications.addClickListener((event) {
      isRedirectNotification.value = true;
      notificationData.value = event.notification.additionalData;

      log("Notification opened: ${event.notification.notificationId}");
      log("isRedirect: ${isRedirectNotification.value}");
      log("Notification data: ${notificationData.value}");

      // Handle navigation based on notification data
      _handleNotificationNavigation(event.notification);
    });

    // When permission changes
    OneSignal.Notifications.addPermissionObserver((stateChanges) {
      log("Permission changed from ${stateChanges.toString()}");
    });

    // When subscription status changes
    OneSignal.User.addObserver((event) {
      log("Push subscription state changed: ${event.current.jsonRepresentation()}");
    });
  }

  // Handle navigation based on notification content
  void _handleNotificationNavigation(OSNotification notification) {
    // Extract routing information from notification data
    final data = notification.additionalData;
    if (data == null) return;

    // Example: Navigate based on notification type
    String? notificationType = data['type'];
    String? targetId = data['target_id'];

    if (notificationType != null && targetId != null) {
      // Navigation logic here - implement using your app's navigation system
      // For example with GetX:
      // Get.toNamed('/details/$targetId');

      log("Should navigate to: $notificationType with ID: $targetId");
    }
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
    } catch (e) {
      log("Error logging out user: $e");
    }
  }
}

// Usage in main.dart
/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize OneSignal
  await OSNotificationService().initializeOneSignal('YOUR_ONESIGNAL_APP_ID');

  runApp(MyApp());
}
*/
// Example of how to use the service in a widget
class NotificationListener extends StatefulWidget {
  final Widget child;

  const NotificationListener({Key? key, required this.child}) : super(key: key);

  @override
  _NotificationListenerState createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  final OSNotificationService _notificationService = OSNotificationService();

  @override
  void initState() {
    super.initState();

    // Listen for notification redirects
    _notificationService.isRedirectNotification.addListener(_handleRedirect);
  }

  void _handleRedirect() {
    if (_notificationService.isRedirectNotification.value) {
      // Handle the redirect here
      final data = _notificationService.notificationData.value;
      log("Handling notification redirect with data: $data");

      // Reset the flag after handling
      _notificationService.resetRedirectFlag();
    }
  }

  @override
  void dispose() {
    _notificationService.isRedirectNotification.removeListener(_handleRedirect);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}