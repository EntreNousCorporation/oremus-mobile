import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  // Contrôleur d'animation pour l'apparition/disparition
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialiser le contrôleur d'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Commence hors écran vers le bas
      end: Offset.zero,          // Termine à sa position normale
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Démarrer l'animation si le lecteur doit être visible au départ
    final audioService = Get.find<AudioPlayerService>();
    if (audioService.showMiniPlayer.value) {
      _animationController.value = 1.0; // Mettre immédiatement à la position finale
    }

    // Écouter les changements de visibilité
    ever(audioService.showMiniPlayer, (bool visible) {
      if (visible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Get.find<AudioPlayerService>();

    return Obx(() {
      // Vérifier si nous sommes sur l'écran Rosaire
      bool isOnRosaryScreen = false;
      try {
        final customHomeController = Get.find<CustomHomeController>();
        isOnRosaryScreen = customHomeController.menus[customHomeController.selectedIndex.value].code == AppConstants.ROSAIRE;
      } catch (e) {
        // En cas d'erreur, on suppose qu'on n'est pas sur l'écran rosaire
      }

      // Si le mini-player ne doit pas être affiché ou si nous sommes sur l'écran rosaire
      if (!audioService.showMiniPlayer.value || isOnRosaryScreen) {
        // Animation de sortie si nécessaire
        if (_animationController.status != AnimationStatus.dismissed &&
            _animationController.status != AnimationStatus.reverse) {
          _animationController.reverse();
        }

        // Ne pas afficher le widget s'il n'y a pas d'animation en cours
        if (_animationController.isDismissed) {
          return const SizedBox.shrink();
        }
      } else {
        // Animation d'entrée si nécessaire
        if (_animationController.status != AnimationStatus.completed &&
            _animationController.status != AnimationStatus.forward) {
          _animationController.forward();
        }
      }

      // Utiliser SlideTransition pour une animation fluide
      return SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            try {
              // Naviguer vers la vue du rosaire via le CustomHomeController
              final customHomeController = Get.find<CustomHomeController>();
              int rosaryIndex = customHomeController.menus.indexWhere((menu) => menu.code == AppConstants.ROSAIRE);

              if (rosaryIndex != -1) {
                customHomeController.doRedirection(rosaryIndex, customHomeController.drawerController);
              }
            } catch (e) {
              // Gérer les erreurs lors de la navigation
            }
          },
          child: Hero(
            tag: 'rosary-player',
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barre de progression
                    StreamBuilder<PositionData>(
                      stream: audioService.positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data ??
                            PositionData(
                              position: Duration.zero,
                              bufferedPosition: Duration.zero,
                              duration: Duration.zero,
                            );

                        final progress = positionData.duration.inMilliseconds > 0
                            ? positionData.position.inMilliseconds /
                            positionData.duration.inMilliseconds
                            : 0.0;

                        final buffered = positionData.duration.inMilliseconds > 0
                            ? positionData.bufferedPosition.inMilliseconds /
                            positionData.duration.inMilliseconds
                            : 0.0;

                        return Stack(
                          children: [
                            Container(
                              height: 3,
                              width: double.infinity,
                              color: Colors.grey[200],
                            ),
                            // Partie mise en buffer (en gris)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 3,
                              width: MediaQuery.of(context).size.width * buffered,
                              color: Colors.grey[400],
                            ),
                            // Partie lue (en vert)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 3,
                              width: MediaQuery.of(context).size.width * progress,
                              color: colorGreenSemiLight,
                            ),
                          ],
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Informations du morceau
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  audioService.currentMystereDetailTitle.value,
                                  style: TextStyles.montserratSemiBold(
                                    textSize: 14,
                                    textColor: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  audioService.currentMystereTitle.value,
                                  style: TextStyles.montserratRegular(
                                    textSize: 12,
                                    textColor: Colors.grey[600]!,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Boutons de contrôle
                          Row(
                            children: [
                              // Bouton reculer
                              _buildControlButton(
                                icon: Icons.replay_10_rounded,
                                onTap: () {
                                  if (!audioService.isLoadingAudio.value) {
                                    audioService.seekBackward();
                                  }
                                },
                                onLongPress: () {
                                  if (!audioService.isLoadingAudio.value) {
                                    audioService.startContinuousSeekBackward();
                                  }
                                },
                                onLongPressEnd: (_) {
                                  audioService.stopContinuousSeek();
                                },
                              ),

                              // Bouton play/pause
                              GestureDetector(
                                onTap: () {
                                  if (!audioService.isLoadingAudio.value) {
                                    audioService.playPause();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Obx(() {
                                    // Afficher un spinner pendant le chargement
                                    if (audioService.isLoadingAudio.value) {
                                      return const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(colorGreenSemiLight),
                                        ),
                                      );
                                    }

                                    // Sinon afficher le bouton play/pause
                                    return Icon(
                                      audioService.isPlaying.value
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: colorGreenSemiLight,
                                      size: 32,
                                    );
                                  }),
                                ),
                              ),

                              // Bouton avancer
                              _buildControlButton(
                                icon: Icons.forward_10_rounded,
                                onTap: () {
                                  if (!audioService.isLoadingAudio.value) {
                                    audioService.seekForward();
                                  }
                                },
                                onLongPress: () {
                                  if (!audioService.isLoadingAudio.value) {
                                    audioService.startContinuousSeekForward();
                                  }
                                },
                                onLongPressEnd: (_) {
                                  audioService.stopContinuousSeek();
                                },
                              ),

                              // Bouton fermer
                              _buildControlButton(
                                icon: Icons.close,
                                iconSize: 24,
                                iconColor: Colors.grey[600]!,
                                onTap: () {
                                  _animationController.reverse().then((_) {
                                    audioService.closeMiniPlayer();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // Widget réutilisable pour les boutons de contrôle
  Widget _buildControlButton({
    required IconData icon,
    double iconSize = 28,
    Color iconColor = colorGreenSemiLight,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Function(LongPressEndDetails)? onLongPressEnd,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}