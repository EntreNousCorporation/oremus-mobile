import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';

class PrestigieuxPlayer extends StatelessWidget {
  const PrestigieuxPlayer({Key? key, required this.audioService, required this.controller}) : super(key: key);

  final AudioPlayerService audioService;
  final RosaryController controller;

  @override
  Widget build(BuildContext context) {
    final theme = RosaryTheme.getTheme(controller.currentColorTheme.value);
    final goldColor = Color.lerp(Colors.amber[800]!, Colors.white, 0.2)!;
    final accentColor = Color.lerp(theme.activeColor, goldColor, 0.3)!;

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
          gradient: LinearGradient(
            colors: [
              Color.lerp(theme.backgroundColor, Colors.white, 0.95)!,
              Color.lerp(theme.backgroundColor, Colors.white, 0.85)!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: 1,
            ),
          ],
          border: Border(
            top: BorderSide(
              color: goldColor.withValues(alpha: 0.5),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ornement supérieur
            Visibility(
              visible: false,
              child: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 2),
                height: 3,
                width: 60,
                decoration: BoxDecoration(
                  color: goldColor.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),

            // Barre de progression prestigieuse
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<PositionData>(
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

                  return Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.inactiveColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Partie mise en buffer
                        Container(
                          width: math.max(0, MediaQuery.of(context).size.width * buffered - 32),
                          decoration: BoxDecoration(
                            color: theme.inactiveColor.withValues(alpha: 0.3),
                          ),
                        ),
                        // Partie lue avec effet de dégradé
                        Container(
                          width: math.max(0, MediaQuery.of(context).size.width * progress - 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor,
                                goldColor,
                                accentColor,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              child: Row(
                children: [
                  // Informations du rosaire avec style prestigieux
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Petit ornement doré
                            Container(
                              width: 3,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: goldColor.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                //audioService.currentMystereDetailTitle.value,
                                'Méditation des mystères',
                                style: TextStyles.montserratSemiBold(
                                  textSize: 14,
                                  textColor: theme.crossColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 11),
                          child: Text(
                            audioService.currentMystereTitle.value,
                            style: TextStyles.montserratRegular(
                              textSize: 12,
                              textColor: Color.lerp(theme.crossColor, Colors.grey[600]!, 0.5)!,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Boutons de contrôle prestigieux
                  Row(
                    children: [
                      // Bouton reculer
                      _buildNewPrestigiousControlButton(
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
                        goldColor: goldColor,
                      ),
                      const SizedBox(width: 12),

                      // Bouton play/pause
                      GestureDetector(
                        onTap: () {
                          if (!audioService.isLoadingAudio.value) {
                            audioService.playPause();
                          }
                        },
                        child: Obx(() {
                          final isPlaying = audioService.isPlaying.value;
                          final isLoading = audioService.isLoadingAudio.value;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cercle extérieur
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.95),
                                    ],
                                    radius: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: goldColor.withValues(alpha: 0.2),
                                      blurRadius: isPlaying ? 8 : 3,
                                      spreadRadius: isPlaying ? 1 : 0,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isPlaying
                                        ? goldColor
                                        : goldColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                              ),

                              // Cercle intérieur coloré
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isPlaying ? 28 : 20,
                                height: isPlaying ? 28 : 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isPlaying ? accentColor : Colors.transparent,
                                  gradient: isPlaying ? LinearGradient(
                                    colors: [
                                      theme.activeColor,
                                      accentColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ) : null,
                                ),
                              ),

                              // Icône ou spinner
                              isLoading
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: isPlaying ? Colors.white : accentColor,
                                size: 24,
                              ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(width: 12),

                      // Bouton avancer
                      _buildNewPrestigiousControlButton(
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
                        goldColor: goldColor,
                      ),
                      const SizedBox(width: 8),

                      // Bouton fermer
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            audioService.closeMiniPlayer();
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.grey[600]!,
                            size: 16,
                          ),
                        ),
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

  Widget _buildNewPrestigiousControlButton({
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Function(LongPressEndDetails)? onLongPressEnd,
    required Color color,
    required Color goldColor,
    double size = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onLongPressEnd: onLongPressEnd,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fond avec dégradé très subtil
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  radius: 0.7,
                ),
              ),
            ),
            // Icône
            Icon(
              icon,
              color: color,
              size: size,
            ),
            // Bordure très fine
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: goldColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
