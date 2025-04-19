import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService.to;

    return Container(
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
                      Container(
                        height: 3,
                        width: MediaQuery.of(context).size.width * buffered,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                        ),
                      ),
                      // Partie lue (en vert)
                      Container(
                        height: 3,
                        width: MediaQuery.of(context).size.width * progress,
                        decoration: const BoxDecoration(
                          color: colorGreenSemiLight,
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
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
                        ),
                        Separators.minimunHorizontal(),

                        // Bouton fermer
                        _buildControlButton(
                          icon: Icons.close,
                          iconColor: Colors.grey[600]!,
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

  Widget _buildControlButton({
    required IconData icon,
    double iconSize = 30,
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
