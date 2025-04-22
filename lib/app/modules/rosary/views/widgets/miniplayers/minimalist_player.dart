import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';

class MinimalistPlayer extends StatelessWidget {
  const MinimalistPlayer({Key? key, required this.audioService, required this.controller}) : super(key: key);

  final AudioPlayerService audioService;
  final RosaryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = RosaryTheme.getTheme(controller.currentColorTheme.value);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: _buildPlayerContent(
        context,
        audioService,
        controller,
        progressBarHeight: 2,
        progressBarRadius: 0,
        bgColor: theme.inactiveColor.withValues(alpha: 0.2),
        bufferedColor: theme.inactiveColor.withValues(alpha: 0.5),
        progressColor: theme.activeColor,
        titleColor: Colors.black87,
        subtitleColor: Colors.grey[600]!,
        iconColor: theme.activeColor,
        closeIconColor: Colors.grey[500]!,
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        useOutlineControls: true,
        controlIconSize: 24,
      ),
    );
  }

  Widget _buildPlayerContent(
      BuildContext context,
      AudioPlayerService audioService,
      RosaryController controller, {
        double progressBarHeight = 3,
        double progressBarRadius = 20,
        Color bgColor = Colors.grey,
        Color bufferedColor = Colors.grey,
        Color progressColor = Colors.red,
        Color titleColor = Colors.black87,
        Color subtitleColor = Colors.grey,
        Color iconColor = Colors.green,
        Color closeIconColor = Colors.grey,
        EdgeInsets contentPadding = const EdgeInsets.all(12.0),
        bool addSeparator = false,
        bool useElevatedControls = false,
        bool useOutlineControls = false,
        double controlIconSize = 30,
      }) {
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
        color: colorTransparent,
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
                      height: progressBarHeight,
                      width: double.infinity,
                      color: bgColor,
                    ),
                    // Partie mise en buffer
                    Container(
                      height: progressBarHeight,
                      width: MediaQuery.of(context).size.width * buffered,
                      decoration: BoxDecoration(
                        color: bufferedColor,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(progressBarRadius),
                        ),
                      ),
                    ),
                    // Partie lue
                    Container(
                      height: progressBarHeight,
                      width: MediaQuery.of(context).size.width * progress,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.horizontal(
                          right: Radius.circular(progressBarRadius),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Ligne séparatrice si demandée
            if (addSeparator)
              Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.1),
              ),

            Padding(
              padding: contentPadding,
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
                            textColor: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          audioService.currentMystereTitle.value,
                          style: TextStyles.montserratRegular(
                            textSize: 12,
                            textColor: subtitleColor,
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
                      useElevatedControls
                          ? _buildElevatedControlButton(
                        icon: Icons.replay_10_rounded,
                        iconSize: controlIconSize,
                        iconColor: iconColor,
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
                      )
                          : useOutlineControls
                          ? _buildOutlineControlButton(
                        icon: Icons.replay_10_rounded,
                        iconSize: controlIconSize,
                        iconColor: iconColor,
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
                      )
                          : _buildControlButton(
                        icon: Icons.replay_10_rounded,
                        iconSize: controlIconSize,
                        iconColor: iconColor,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                                ),
                              );
                            }

                            // Sinon afficher le bouton play/pause
                            return Icon(
                              audioService.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: iconColor,
                              size: 32,
                            );
                          }),
                        ),
                      ),
                      Separators.minimunHorizontal(),

                      // Bouton avancer
                      useElevatedControls
                          ? _buildElevatedControlButton(
                        icon: Icons.forward_10_rounded,
                        iconSize: controlIconSize,
                        iconColor: iconColor,
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
                      )
                          : useOutlineControls
                          ? _buildOutlineControlButton(
                        icon: Icons.forward_10_rounded,
                        iconSize: controlIconSize,
                        iconColor: iconColor,
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
                      )
                          : _buildControlButton(
                        icon: Icons.forward_10_rounded,
                        iconSize: controlIconSize,
                        iconColor: iconColor,
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
                      Separators.minimunHorizontal(),

                      // Bouton fermer
                      useElevatedControls
                          ? _buildElevatedControlButton(
                        icon: Icons.close,
                        iconSize: controlIconSize - 6,
                        iconColor: closeIconColor,
                        onTap: () {
                          audioService.closeMiniPlayer();
                        },
                      )
                          : useOutlineControls
                          ? _buildOutlineControlButton(
                        icon: Icons.close,
                        iconSize: controlIconSize - 6,
                        iconColor: closeIconColor,
                        onTap: () {
                          audioService.closeMiniPlayer();
                        },
                      )
                          : _buildControlButton(
                        icon: Icons.close,
                        iconSize: controlIconSize - 6,
                        iconColor: closeIconColor,
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
    );
  }

  Widget _buildElevatedControlButton({
    required IconData icon,
    double iconSize = 26,
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildOutlineControlButton({
    required IconData icon,
    double iconSize = 24,
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }

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
}
