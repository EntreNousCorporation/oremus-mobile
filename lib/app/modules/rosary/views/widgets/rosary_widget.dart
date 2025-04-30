import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';

class RosaryWidget extends StatefulWidget {
  const RosaryWidget({Key? key, required this.audioService}) : super(key: key);

  final AudioPlayerService audioService;

  @override
  State<RosaryWidget> createState() => _RosaryWidgetState();
}

class _RosaryWidgetState extends State<RosaryWidget>
    with SingleTickerProviderStateMixin {

  // Animation controller pour l'effet de pulsation
  late AnimationController _animationController;

  static const ROSARY_COUNT_NUT = 59;

  @override
  void initState() {
    // Initialiser l'animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RosaryController>(builder: (controller) {
      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circle representing the rosary
            Container(
              width: Platform.isAndroid
                  ? Get.width * 0.8
                  : Get.width * 0.85,
              height: Platform.isAndroid
                  ? Get.width * 0.8
                  : Get.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: StreamBuilder<PositionData>(
                  stream: widget.audioService.positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                          position: Duration.zero,
                          bufferedPosition: Duration.zero,
                          duration: Duration.zero,
                        );

                    // Calculer le pourcentage pour le rosaire
                    final progress = positionData
                        .duration.inMilliseconds >
                        0
                        ? positionData.position.inMilliseconds /
                        positionData.duration.inMilliseconds
                        : 0.0;

                    return CustomPaint(
                      painter: RosaryPainter(
                        activeBeadIndex:
                        (progress * ROSARY_COUNT_NUT).round(),
                        style: controller.currentStyle.value,
                        colorTheme:
                        controller.currentColorTheme.value,
                      ),
                    );
                  }),
            ),

            // Contrôles de lecture avec avance/recul
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton reculer
                GestureDetector(
                  onTap: () {
                    if (!widget.audioService.isLoadingAudio.value) {
                      widget.audioService.seekBackward();
                    }
                  },
                  onLongPress: () {
                    if (!widget.audioService.isLoadingAudio.value) {
                      widget.audioService.startContinuousSeekBackward();
                    }
                  },
                  onLongPressEnd: (_) {
                    widget.audioService.stopContinuousSeek();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.replay_10_rounded,
                        color: colorGreenSemiLight,
                        size: 28,
                      ),
                    ),
                  ),
                ),

                // Espace
                const SizedBox(width: 16),

                // Bouton play/pause central
                AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, child) {
                      return Transform.scale(
                        scale: widget.audioService.isPlaying.value
                            ? 1.0 +
                            (_animationController.value * 0.1)
                            : 1.0,
                        child: GestureDetector(
                          onTap: () {
                            // Ne pas permettre la lecture pendant le chargement
                            if (widget.audioService
                                .isLoadingAudio.value) {
                              return;
                            }

                            // Appel à la fonction playPause et forcer une mise à jour
                            widget.audioService.playPause();

                            // Forcer une mise à jour du contrôleur et de l'UI
                            Future.delayed(Duration.zero, () {
                              controller.update();
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.audioService.isPlaying.value
                                  ? colorGreenSemiLight
                                  : Colors.white,
                              border: Border.all(
                                  color: colorGreenSemiLight,
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: colorGreenSemiLight
                                      .withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius:
                                  widget.audioService.isPlaying.value
                                      ? 5
                                      : 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Obx(() {
                                // Afficher un spinner pendant le chargement
                                if (widget.audioService
                                    .isLoadingAudio.value) {
                                  return const CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                        colorGreenSemiLight),
                                  );
                                }

                                // Sinon afficher le bouton play/pause
                                return Icon(
                                  widget.audioService.isPlaying.value
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color:
                                  widget.audioService.isPlaying.value
                                      ? Colors.white
                                      : colorGreenSemiLight,
                                  size: 40,
                                );
                              }),
                            ),
                          ),
                        ),
                      );
                    }),

                // Espace
                const SizedBox(width: 16),

                // Bouton avancer
                GestureDetector(
                  onTap: () {
                    if (!widget.audioService.isLoadingAudio.value) {
                      widget.audioService.seekForward();
                    }
                  },
                  onLongPress: () {
                    if (!widget.audioService.isLoadingAudio.value) {
                      widget.audioService.startContinuousSeekForward();
                    }
                  },
                  onLongPressEnd: (_) {
                    widget.audioService.stopContinuousSeek();
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withValues(alpha: 0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.forward_10_rounded,
                        color: colorGreenSemiLight,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
