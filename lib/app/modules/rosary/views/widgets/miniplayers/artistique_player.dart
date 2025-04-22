import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/artistic_progress_painter.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';

class ArtistiquePlayer extends StatelessWidget {
  const ArtistiquePlayer({Key? key, required this.audioService, required this.controller}) : super(key: key);

  final AudioPlayerService audioService;
  final RosaryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = RosaryTheme.getTheme(controller.currentColorTheme.value);

    return GestureDetector(
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
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.lerp(theme.backgroundColor, Colors.white, 0.9)!,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: theme.activeColor.withValues(alpha: 0.3),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de progression artistique
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

                // Création d'une barre de progression stylisée avec Path
                return SizedBox(
                  height: 4,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ArtisticProgressPainter(
                      progress: progress,
                      activeColor: theme.activeColor,
                      inactiveColor: theme.inactiveColor.withValues(alpha: 0.4),
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  // Informations du rosaire avec effet artistique
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          //audioService.currentMystereDetailTitle.value,
                          'Méditation des mystères',
                          style: TextStyles.montserratSemiBold(
                            textSize: 14,
                            textColor: theme.crossColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          audioService.currentMystereTitle.value,
                          style: TextStyles.montserratRegular(
                            textSize: 12,
                            textColor: Color.lerp(theme.crossColor, Colors.grey[600]!, 0.3)!,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Boutons de contrôle avec style artistique
                  Row(
                    children: [
                      // Bouton reculer
                      _buildArtisticControlButton(
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
                        color: theme.activeColor,
                      ),
                      const SizedBox(width: 10),

                      // Bouton play/pause
                      GestureDetector(
                        onTap: () {
                          if (!audioService.isLoadingAudio.value) {
                            audioService.playPause();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: audioService.isPlaying.value
                                ? theme.activeColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.activeColor,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Obx(() {
                            // Afficher un spinner pendant le chargement
                            if (audioService.isLoadingAudio.value) {
                              return SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.activeColor),
                                ),
                              );
                            }

                            // Sinon afficher le bouton play/pause
                            return Icon(
                              audioService.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: theme.activeColor,
                              size: 32,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Bouton avancer
                      _buildArtisticControlButton(
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
                        color: theme.activeColor,
                      ),
                      const SizedBox(width: 10),

                      // Bouton fermer
                      _buildArtisticControlButton(
                        icon: Icons.close,
                        onTap: () {
                          audioService.closeMiniPlayer();
                        },
                        color: Color.lerp(theme.crossColor, Colors.grey[600]!, 0.5)!,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Platform.isIOS ? Separators.minimunVertical() : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisticControlButton({
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Function(LongPressEndDetails)? onLongPressEnd,
    required Color color,
    double size = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
