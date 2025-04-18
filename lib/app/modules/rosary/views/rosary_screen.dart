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
    )..repeat(reverse: true);

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
        return Hero(
          tag: 'rosary-player',
          child: Material(
            color: colorTransparent,
            child: ListView(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 0,
              ),
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
                  child: Obx(() => Column(
                        children: [
                          Text(
                            audioService
                                .mysteres[audioService.currentMystereIndex.value],
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Current Mystery Title
                          Text(
                            audioService.mystereDetails[
                                    audioService.currentMystereIndex.value]
                                [audioService.currentMystereDetailIndex.value],
                            style: TextStyles.montserratSemiBold(
                              textSize: TextSizes.sixteen,
                              textColor: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // Afficher l'indicateur de streaming si actif
                          if (audioService.isStreamingMode.value)
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        colorGreenSemiLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.wifi_tethering,
                                        size: 14,
                                        color: colorGreenSemiLight,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Streaming',
                                        style: TextStyles.montserratRegular(
                                          textSize: TextSizes.twelve,
                                          textColor: colorGreenSemiLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                          // Afficher l'état de téléchargement si en cours
                          if (audioService.isDownloading.value)
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            colorGreenSemiLight),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chargement...',
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorGreenSemiLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                          // Afficher les messages d'erreur s'il y en a
                          if (audioService.errorMessage.value.isNotEmpty)
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  audioService.errorMessage.value,
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.fourteen,
                                    textColor: Colors.red,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    audioService.errorMessage.value = '';
                                    audioService.loadAudio(
                                        audioService.currentMystereIndex.value,
                                        audioService
                                            .currentMystereDetailIndex.value);
                                  },
                                  child: Text(
                                    'Réessayer',
                                    style: TextStyles.montserratSemiBold(
                                      textSize: TextSizes.fourteen,
                                      textColor: colorGreenSemiLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )),
                ),

                const SizedBox(height: 50),

                // Rosary Visualization
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circle representing the rosary
                      Container(
                        width: Get.width * 0.8,
                        height: Get.width * 0.8,
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
                              final progress =
                                  positionData.duration.inMilliseconds > 0
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
                            }),
                      ),

                      // Contrôles de lecture avec avance/recul
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bouton reculer
                          GestureDetector(
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
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
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
                                  scale: audioService.isPlaying.value
                                      ? 1.0 + (_animationController.value * 0.1)
                                      : 1.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      // Ne pas permettre la lecture pendant le chargement
                                      if (audioService.isLoadingAudio.value) return;

                                      // Appel à la fonction playPause et forcer une mise à jour
                                      audioService.playPause();

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
                                            spreadRadius:
                                                audioService.isPlaying.value
                                                    ? 5
                                                    : 0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Obx(() {
                                          // Afficher un spinner pendant le chargement
                                          if (audioService.isLoadingAudio.value) {
                                            return const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      colorGreenSemiLight),
                                            );
                                          }

                                          // Sinon afficher le bouton play/pause
                                          return Icon(
                                            audioService.isPlaying.value
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: audioService.isPlaying.value
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
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
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
                ),

                const SizedBox(height: 50),

                // Audio progress bar avec indication du buffer
                StreamBuilder<PositionData>(
                    stream: audioService.positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data ??
                          PositionData(
                            position: Duration.zero,
                            bufferedPosition: Duration.zero,
                            duration: Duration.zero,
                          );

                      // Calculer le pourcentage de progression et du buffer
                      final progress = positionData.duration.inMilliseconds > 0
                          ? positionData.position.inMilliseconds /
                              positionData.duration.inMilliseconds
                          : 0.0;

                      final buffered = positionData.duration.inMilliseconds > 0
                          ? positionData.bufferedPosition.inMilliseconds /
                              positionData.duration.inMilliseconds
                          : 0.0;

                      return Column(
                        children: [
                          // Barre de progression avec indication du buffer pour le streaming
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                // Partie mise en buffer
                                Row(
                                  children: [
                                    Container(
                                      width: (Get.width - 80) * buffered,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ],
                                ),
                                // Partie lue
                                Row(
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
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Durée actuelle / totale
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  audioService
                                      .formatDuration(positionData.position),
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.fourteen,
                                    textColor: Colors.grey[600]!,
                                  ),
                                ),
                                Text(
                                  audioService
                                      .formatDuration(positionData.duration),
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
                    }),

                const SizedBox(height: 20),

                // Contrôles de navigation
                Visibility(
                  visible: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Bouton précédent
                        IconButton(
                          onPressed: () => audioService.navigateToPreviousMystery(),
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: colorGreenSemiLight,
                            size: 36,
                          ),
                        ),

                        // Espace pour le bouton central
                        const SizedBox(width: 80),

                        // Bouton suivant
                        IconButton(
                          onPressed: () => audioService.navigateToNextMystery(),
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: colorGreenSemiLight,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
