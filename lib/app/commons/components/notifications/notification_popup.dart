import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_v3/flutter_html.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';

class NotificationPopup extends StatelessWidget {
  final String title;
  final String contents;
  final String? notificationType;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const NotificationPopup({
    Key? key,
    required this.title,
    required this.contents,
    this.notificationType,
    this.onDismiss,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // Utilisation de Html pour rendre le contenu HTML
              SizedBox(
                width: double.infinity,
                child: Html(
                  data: contents,
                  style: {
                    '#': Style(
                      fontFamily: 'montserrat_bold',
                      fontSize: FontSize(
                        TextSizes.sixteen,
                      ),
                      margin: Margins.zero,
                    )
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (onDismiss != null) onDismiss!();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Fermer"),
                  ),
                  if (onAction != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onAction!();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        "Voir plus",
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
            child: _getNotificationIcon(),
          ),
        ),
      ],
    );
  }

  Widget _getNotificationIcon() {
    IconData iconData;

    switch (notificationType) {
      case 'BROADCAST_MESSAGE':
        iconData = Icons.campaign;
        break;
      case 'PRAYER_INTENTION':
        iconData = Icons.volunteer_activism;
        break;
      case 'PRAYER_REMINDER':
        iconData = Icons.access_alarm;
        break;
      default:
        iconData = Icons.notifications;
    }

    return Icon(
      iconData,
      color: Colors.white,
      size: 50,
    );
  }

  // Méthode statique pour afficher le popup facilement
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String contents,
    String? notificationType,
    VoidCallback? onDismiss,
    VoidCallback? onAction,
  }) async {
    return showModal(
      context: context,
      configuration: const FadeScaleTransitionConfiguration(
        transitionDuration: Duration(milliseconds: 350),
        reverseTransitionDuration: Duration(milliseconds: 100),
        barrierDismissible: false,
      ),
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      builder: (BuildContext context) {
        return NotificationPopup(
          title: title,
          contents: contents,
          notificationType: notificationType,
          onDismiss: onDismiss,
          onAction: onAction,
        );
      },
    );
  }
}
