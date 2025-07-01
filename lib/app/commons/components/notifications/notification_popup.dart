import 'dart:developer';
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html_v3/flutter_html.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Calculer la hauteur maximale disponible
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8; // 80% de la hauteur d'écran
    final contentMaxHeight = maxHeight - 160; // Soustraire l'espace pour l'icône et les boutons

    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
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

              // 🎯 CONTENU SCROLLABLE avec hauteur flexible
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: contentMaxHeight,
                  ),
                  child: Scrollbar(
                    thumbVisibility: true, // Afficher la scrollbar
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 8), // Espace pour la scrollbar
                      child: SizedBox(
                        width: double.infinity,
                        child: Html(
                          data: contents,
                          style: {
                            '#': Style(
                              fontFamily: 'montserrat_bold',
                              fontSize: FontSize(TextSizes.sixteen),
                              margin: Margins.zero,
                            ),
                            // Style pour les liens
                            'a': Style(
                              color: Theme.of(context).primaryColor,
                              textDecoration: TextDecoration.underline,
                              textDecorationColor: Theme.of(context).primaryColor,
                            ),
                            // Améliorer l'espacement pour les longs contenus
                            'p': Style(
                              margin: Margins.only(bottom: 8),
                            ),
                            'br': Style(
                              margin: Margins.only(bottom: 4),
                            ),
                          },
                          // Gestion des clics sur les liens
                          onLinkTap: (url, renderContext, attributes, element) {
                            _handleLinkTap(url);
                          },
                          // Alternative pour les anciennes versions
                          onAnchorTap: (url, renderContext, attributes, element) {
                            _handleLinkTap(url);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🎯 BOUTONS TOUJOURS VISIBLES EN BAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _handleDismiss(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text("Fermer"),
                    ),
                  ),
                  if (onAction != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _handleAction(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          "Voir plus",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // 🎯 ICÔNE POSITIONNÉE AU-DESSUS
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

  // Nouvelle méthode pour gérer les clics sur les liens
  void _handleLinkTap(String? url) async {
    if (url == null || url.isEmpty) {
      log("❌ URL vide ou null");
      return;
    }

    try {
      log("🔗 Tentative d'ouverture du lien: $url");

      // Vérifier si l'URL est valide
      final uri = Uri.parse(url);

      // Vérifier si l'application peut ouvrir ce lien
      if (await canLaunchUrl(uri)) {
        // Ouvrir le lien dans le navigateur externe
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Force l'ouverture dans le navigateur
        );
        log("✅ Lien ouvert avec succès: $url");
      } else {
        log("❌ Impossible d'ouvrir le lien: $url");
      }
    } catch (e) {
      log("❌ Erreur lors de l'ouverture du lien: $e");

      // En cas d'erreur, on peut toujours essayer d'ouvrir avec launchUrl
      try {
        final uri = Uri.parse(url);
        await launchUrl(uri);
      } catch (fallbackError) {
        log("❌ Erreur lors du fallback d'ouverture: $fallbackError");
      }
    }
  }

  // Gestion sécurisée de la fermeture
  void _handleDismiss(BuildContext context) {
    try {
      log("🔻 Tentative de fermeture du popup de notification");

      // Fermer le dialog de manière sécurisée
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        log("✅ Dialog fermé avec succès");
      } else {
        log("⚠️ Impossible de fermer le dialog - pas dans la pile de navigation");
      }

      // Appeler le callback de fermeture après un délai pour s'assurer que le dialog est fermé
      Future.delayed(const Duration(milliseconds: 100), () {
        if (onDismiss != null) {
          try {
            onDismiss!();
            log("✅ Callback onDismiss exécuté");
          } catch (e) {
            log("❌ Erreur lors de l'exécution du callback onDismiss: $e");
          }
        }
      });
    } catch (e) {
      log("❌ Erreur lors de la fermeture du popup: $e");
      // Appeler quand même le callback en cas d'erreur
      if (onDismiss != null) {
        try {
          onDismiss!();
        } catch (callbackError) {
          log("❌ Erreur lors de l'exécution du callback de fallback: $callbackError");
        }
      }
    }
  }

  // Gestion sécurisée de l'action
  void _handleAction(BuildContext context) {
    try {
      log("🎯 Tentative d'exécution de l'action du popup");

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        log("✅ Dialog fermé avant l'action");
      }

      // Exécuter l'action après un délai
      Future.delayed(const Duration(milliseconds: 100), () {
        if (onAction != null) {
          try {
            onAction!();
            log("✅ Callback onAction exécuté");
          } catch (e) {
            log("❌ Erreur lors de l'exécution du callback onAction: $e");
          }
        }

        // Appeler aussi onDismiss pour nettoyer l'état
        if (onDismiss != null) {
          try {
            onDismiss!();
            log("✅ Callback onDismiss exécuté après l'action");
          } catch (e) {
            log("❌ Erreur lors de l'exécution du callback onDismiss après l'action: $e");
          }
        }
      });
    } catch (e) {
      log("❌ Erreur lors de l'exécution de l'action: $e");
      // Callbacks de fallback
      if (onAction != null) {
        try {
          onAction!();
        } catch (actionError) {
          log("❌ Erreur lors de l'exécution du callback d'action de fallback: $actionError");
        }
      }
      if (onDismiss != null) {
        try {
          onDismiss!();
        } catch (dismissError) {
          log("❌ Erreur lors de l'exécution du callback de fermeture de fallback: $dismissError");
        }
      }
    }
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
    try {
      log("🎯 Tentative d'affichage du popup de notification");
      log("📋 Titre: $title");
      log("📋 Type: $notificationType");

      // Vérifier que le contexte est valide
      if (!context.mounted) {
        log("❌ Contexte non monté, impossible d'afficher le popup");
        if (onDismiss != null) onDismiss();
        return;
      }

      await showModal(
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

      log("✅ Popup affiché avec succès");
    } catch (e) {
      log("❌ Erreur lors de l'affichage du popup: $e");
      // Appeler onDismiss en cas d'erreur pour éviter de bloquer la file d'attente
      if (onDismiss != null) {
        try {
          onDismiss();
        } catch (callbackError) {
          log("❌ Erreur lors de l'exécution du callback de fallback dans show(): $callbackError");
        }
      }
    }
  }
}