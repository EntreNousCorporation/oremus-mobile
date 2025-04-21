import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart'; // Ajout du contrôleur du chapelet
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/rosary_painter_variant.dart'; // Ajout des styles et thèmes

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService.to;
    // Obtenir le contrôleur du chapelet pour accéder au style et thème actuels
    final RosaryController rosaryController = Get.find<RosaryController>();

    // Obtenir le thème de couleurs actuel
    final RosaryTheme currentTheme = RosaryTheme.getTheme(rosaryController.currentColorTheme.value);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Adapter la couleur de fond en fonction du style
        color: _getBackgroundColor(rosaryController.currentStyle.value, currentTheme),
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
        child: Container(
          color: colorTransparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barre de progression - adapter les couleurs
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
                        // Fond de la barre de progression adapté au thème
                        color: currentTheme.inactiveColor.withValues(alpha: 0.3),
                      ),
                      // Partie mise en buffer (en couleur du thème atténuée)
                      Container(
                        height: 3,
                        width: MediaQuery.of(context).size.width * buffered,
                        decoration: BoxDecoration(
                          color: currentTheme.inactiveColor,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                        ),
                      ),
                      // Partie lue (en couleur active du thème)
                      Container(
                        height: 3,
                        width: MediaQuery.of(context).size.width * progress,
                        decoration: BoxDecoration(
                          color: currentTheme.activeColor,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                        ),
                      ),
                    ],
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Informations du rosaire
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            //audioService.currentMystereDetailTitle.value,
                            'Méditation des mystères',
                            style: TextStyles.montserratRegular(
                              textSize: 12,
                              // Couleur du texte adaptée au style
                              textColor: _getTextColor(rosaryController.currentStyle.value, currentTheme),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            audioService.currentMystereTitle.value,
                            style: TextStyles.montserratSemiBold(
                              textSize: 14,
                              textColor: _getSubtitleColor(rosaryController.currentStyle.value, currentTheme),
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
                          // Utiliser la couleur active du thème
                          iconColor: currentTheme.activeColor,
                        ),
                        Separators.minimunHorizontal(),

                        // Bouton play/pause
                        GestureDetector(
                          onTap: () {
                            if (!audioService.isLoadingAudio.value) {
                              audioService.playPause();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: colorTransparent,
                            child: Obx(() {
                              // Afficher un spinner pendant le chargement
                              if (audioService.isLoadingAudio.value) {
                                return SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    // Utiliser la couleur active du thème
                                    valueColor: AlwaysStoppedAnimation<Color>(currentTheme.activeColor),
                                  ),
                                );
                              }

                              // Sinon afficher le bouton play/pause
                              return Icon(
                                audioService.isPlaying.value
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                // Utiliser la couleur active du thème  
                                color: currentTheme.activeColor,
                                size: 32,
                              );
                            }),
                          ),
                        ),
                        Separators.minimunHorizontal(),

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
                          // Utiliser la couleur active du thème
                          iconColor: currentTheme.activeColor,
                        ),
                        Separators.minimunHorizontal(),

                        // Bouton fermer
                        _buildControlButton(
                          icon: Icons.close,
                          // Pour le bouton fermer, utiliser une couleur plus neutre
                          iconColor: _getCloseButtonColor(rosaryController.currentStyle.value, currentTheme),
                          onTap: () {
                            audioService.closeMiniPlayer();
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
    );
  }

  // Méthode modifiée pour prendre en compte la couleur passée en paramètre
  Widget _buildControlButton({
    required IconData icon,
    double iconSize = 30,
    required Color iconColor,
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
        color: colorTransparent,
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }

  // Méthode pour obtenir la couleur de fond en fonction du style
  Color _getBackgroundColor(RosaryStyle style, RosaryTheme theme) {
    switch (style) {
      case RosaryStyle.elegant:
        return Colors.white.withValues(alpha: 0.95);
      case RosaryStyle.minimalist:
        return Colors.white;
      case RosaryStyle.modern:
        return theme.backgroundColor.withValues(alpha: 0.95);
      case RosaryStyle.artistique:
        return theme.backgroundColor.withValues(alpha: 0.9);
      case RosaryStyle.prestigieux:
        return Color.lerp(theme.backgroundColor, Colors.white, 0.7)!;
      case RosaryStyle.classic:
      default:
        return Colors.white;
    }
  }

  // Méthode pour obtenir la couleur du texte principal
  Color _getTextColor(RosaryStyle style, RosaryTheme theme) {
    switch (style) {
      case RosaryStyle.elegant:
      case RosaryStyle.prestigieux:
        return Color.lerp(theme.crossColor, Colors.black87, 0.3)!;
      case RosaryStyle.artistique:
        return theme.crossColor;
      case RosaryStyle.modern:
      case RosaryStyle.minimalist:
        return Colors.black87;
      case RosaryStyle.classic:
      default:
        return Colors.black87;
    }
  }

  // Méthode pour obtenir la couleur du sous-titre
  Color _getSubtitleColor(RosaryStyle style, RosaryTheme theme) {
    switch (style) {
      case RosaryStyle.elegant:
      case RosaryStyle.prestigieux:
        return Color.lerp(theme.crossColor, Colors.grey[600]!, 0.5)!;
      case RosaryStyle.artistique:
        return Color.lerp(theme.crossColor, Colors.grey[600]!, 0.3)!;
      case RosaryStyle.modern:
      case RosaryStyle.minimalist:
      case RosaryStyle.classic:
      default:
        return Colors.grey[600]!;
    }
  }

  // Méthode pour obtenir la couleur du bouton de fermeture
  Color _getCloseButtonColor(RosaryStyle style, RosaryTheme theme) {
    switch (style) {
      case RosaryStyle.elegant:
      case RosaryStyle.prestigieux:
        return Color.lerp(theme.crossColor, Colors.grey[600]!, 0.7)!;
      case RosaryStyle.artistique:
        return Color.lerp(theme.crossColor, Colors.grey[600]!, 0.5)!;
      case RosaryStyle.modern:
      case RosaryStyle.minimalist:
      case RosaryStyle.classic:
      default:
        return Colors.grey[600]!;
    }
  }
}
