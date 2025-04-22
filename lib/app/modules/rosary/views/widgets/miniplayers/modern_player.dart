import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';

class ModernPlayer extends StatelessWidget {
  const ModernPlayer({Key? key, required this.audioService, required this.controller}) : super(key: key);

  final AudioPlayerService audioService;
  final RosaryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = RosaryTheme.getTheme(controller.currentColorTheme.value);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.lerp(theme.backgroundColor, Colors.white, 0.7)!,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.activeColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
            spreadRadius: 1,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barre de progression avec hauteur augmentée
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
                      height: 6,
                      width: double.infinity,
                      color: theme.inactiveColor.withValues(alpha: 0.15),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width * buffered,
                      color: theme.inactiveColor.withValues(alpha: 0.5),
                    ),
                    Container(
                      height: 6,
                      width: MediaQuery.of(context).size.width * progress,
                      color: theme.activeColor,
                    ),
                  ],
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                            textColor: Color.lerp(theme.crossColor, Colors.grey[600]!, 0.4)!,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Boutons de contrôle dans un design moderne
                  Row(
                    children: [
                      // Bouton reculer
                      _buildModernControlButton(
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
                        size: 26,
                      ),
                      const SizedBox(width: 12),

                      // Bouton play/pause
                      GestureDetector(
                        onTap: () {
                          if (!audioService.isLoadingAudio.value) {
                            audioService.playPause();
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.activeColor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Obx(() {
                            // Afficher un spinner pendant le chargement
                            if (audioService.isLoadingAudio.value) {
                              return const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              );
                            }

                            // Sinon afficher le bouton play/pause
                            return Icon(
                              audioService.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 24,
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Bouton avancer
                      _buildModernControlButton(
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
                        size: 26,
                      ),
                      const SizedBox(width: 12),

                      // Bouton fermer
                      _buildModernControlButton(
                        icon: Icons.close,
                        onTap: () {
                          audioService.closeMiniPlayer();
                        },
                        color: Colors.grey[600]!,
                        size: 20,
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

  Widget _buildModernControlButton({
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Function(LongPressEndDetails)? onLongPressEnd,
    required Color color,
    double size = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        padding: const EdgeInsets.all(4),
        color: colorTransparent,
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
