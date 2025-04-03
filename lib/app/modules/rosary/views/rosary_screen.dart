import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/rosary_painter.dart';

class RosaryScreen extends StatefulWidget {
  const RosaryScreen({Key? key}) : super(key: key);

  @override
  State<RosaryScreen> createState() => _RosaryScreenState();
}

class _RosaryScreenState extends State<RosaryScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller pour l'effet de pulsation
  late AnimationController _animationController;

  // Référence au service audio
  late AudioPlayerService audioService;

  @override
  void initState() {
    super.initState();

    // Initialiser l'animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
      ..repeat(reverse: true);

    // Obtenir le service audio
    audioService = AudioPlayerService.to;

    // Charger l'audio initial si nécessaire
    if (!audioService.showMiniPlayer.value) {
      audioService.loadAudio(0, 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RosaryController>(
      builder: (controller) {
        return Column(
          children: [
            // Mystères Selector
            Visibility(
              visible: false,
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: audioService.mysteres.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        audioService.loadAudio(index, 0);
                      },
                      child: Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: audioService.currentMystereIndex.value == index
                              ? colorGreenSemiLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              getMystereIcon(index),
                              color: audioService.currentMystereIndex.value ==
                                  index
                                  ? Colors.white
                                  : colorGreenSemiLight,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              child: Text(
                                audioService.mysteres[index],
                                textAlign: TextAlign.center,
                                style: TextStyles.montserratSemiBold(
                                  textSize: TextSizes.twelve,
                                  textColor: audioService.currentMystereIndex
                                      .value == index
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                children: [
                  // Current mystery info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Obx(() =>
                        Column(
                          children: [
                            Text(
                              audioService.mysteres[audioService
                                  .currentMystereIndex.value],
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Mystery detail selection
                            Visibility(
                              visible: false,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: audioService
                                      .mystereDetails[audioService
                                      .currentMystereIndex.value].length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        audioService.loadAudio(
                                            audioService.currentMystereIndex
                                                .value, index);
                                      },
                                      child: Container(
                                        width: 40,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: audioService
                                              .currentMystereDetailIndex
                                              .value == index
                                              ? colorGreenSemiLight
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyles.montserratBold(
                                              textSize: TextSizes.fourteen,
                                              textColor: audioService
                                                  .currentMystereDetailIndex
                                                  .value == index
                                                  ? Colors.white
                                                  : Colors.grey[600]!,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            //const SizedBox(height: 20),

                            // Current Mystery Title
                            Text(
                              audioService.mystereDetails[audioService
                                  .currentMystereIndex.value][audioService
                                  .currentMystereDetailIndex.value],
                              style: TextStyles.montserratSemiBold(
                                textSize: TextSizes.sixteen,
                                textColor: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                  ),

                  const SizedBox(height: 30),

                  // Rosary Visualization
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circle representing the rosary
                        Container(
                          width: Get.width * 0.85,
                          height: Get.width * 0.85,
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
                              stream: audioService.positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data ??
                                    PositionData(
                                      position: Duration.zero,
                                      bufferedPosition: Duration.zero,
                                      duration: Duration.zero,
                                    );

                                // Calculer le pourcentage pour le rosaire
                                final progress = positionData.duration
                                    .inMilliseconds > 0
                                    ? positionData.position.inMilliseconds /
                                    positionData.duration.inMilliseconds
                                    : 0.0;

                                return CustomPaint(
                                  painter: RosaryPainter(
                                    beadCount: 50,
                                    activeBeadIndex: (progress * 50).round(),
                                    activeColor: colorGreenSemiLight,
                                    inactiveColor: Colors.grey[300]!,
                                  ),
                                );
                              }
                          ),
                        ),

                        // Center icon that pulses when playing
                        AnimatedBuilder(
                            animation: _animationController,
                            builder: (_, child) {
                              return Transform.scale(
                                scale: audioService.isPlaying.value
                                    ? 1.0 + (_animationController.value * 0.1)
                                    : 1.0,
                                child: GestureDetector(
                                  onTap: () {
                                    // Appel à la fonction playPause et forcer une mise à jour
                                    audioService.playPause();

                                    // Forcer une mise à jour du contrôleur et de l'UI
                                    Future.delayed(Duration.zero, () {
                                      controller.update();
                                    });
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: audioService.isPlaying.value
                                          ? colorGreenSemiLight
                                          : Colors.white,
                                      border: Border.all(
                                          color: colorGreenSemiLight, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorGreenSemiLight.withValues(
                                              alpha: 0.2),
                                          blurRadius: 10,
                                          spreadRadius: audioService.isPlaying
                                              .value ? 5 : 0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Obx(() => Icon(
                                        audioService.isPlaying.value ? Icons
                                            .pause_rounded : Icons
                                            .play_arrow_rounded,
                                        color: audioService.isPlaying.value
                                            ? Colors.white
                                            : colorGreenSemiLight,
                                        size: 50,
                                      )),
                                    ),
                                  ),
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Audio progress bar
                  StreamBuilder<PositionData>(
                      stream: audioService.positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data ??
                            PositionData(
                              position: Duration.zero,
                              bufferedPosition: Duration.zero,
                              duration: Duration.zero,
                            );

                        // Calculer le pourcentage de progression
                        final progress = positionData.duration.inMilliseconds >
                            0
                            ? positionData.position.inMilliseconds /
                            positionData.duration.inMilliseconds
                            : 0.0;

                        return Column(
                          children: [
                            // Barre de progression
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: (Get.width - 80) * progress,
                                    decoration: BoxDecoration(
                                      color: colorGreenSemiLight,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Durée actuelle / totale
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    audioService.formatDuration(
                                        positionData.position),
                                    style: TextStyles.montserratRegular(
                                      textSize: TextSizes.fourteen,
                                      textColor: Colors.grey[600]!,
                                    ),
                                  ),
                                  Text(
                                    audioService.formatDuration(
                                        positionData.duration),
                                    style: TextStyles.montserratRegular(
                                      textSize: TextSizes.fourteen,
                                      textColor: Colors.grey[600]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                  ),

                  const SizedBox(height: 30),

                  // Audio controls
                  Visibility(
                    visible: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Previous button
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: colorGreenSemiLight,
                            size: 36,
                          ),
                          onPressed: audioService.navigateToPreviousMystery,
                        ),

                        const SizedBox(width: 20),

                        // Play/Pause button
                        Obx(() =>
                            GestureDetector(
                              onTap: audioService.playPause,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: audioService.isPlaying.value
                                      ? colorGreenSemiLight.withValues(
                                      alpha: 0.2)
                                      : Colors.white,
                                  border: Border.all(
                                    color: colorGreenSemiLight,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  audioService.isPlaying.value ? Icons
                                      .pause_rounded : Icons.play_arrow_rounded,
                                  color: colorGreenSemiLight,
                                  size: 36,
                                ),
                              ),
                            )),

                        const SizedBox(width: 20),

                        // Next button
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: colorGreenSemiLight,
                            size: 36,
                          ),
                          onPressed: audioService.navigateToNextMystery,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get icon for each mystère
  IconData getMystereIcon(int index) {
    switch (index) {
      case 0:
        return Icons.brightness_5_rounded; // Joyeux
      case 1:
        return Icons.lightbulb_outline_rounded; // Lumineux
      case 2:
        return Icons.favorite_border_rounded; // Douloureux
      case 3:
        return Icons.star_border_rounded; // Glorieux
      default:
        return Icons.help_outline_rounded;
    }
  }
}
