import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/animated_image_displayer.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/animated_placeholder_waveform.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/waveform_painter.dart';
import 'package:oremusapp/generated/assets.dart';

class RosaryScreen extends StatefulWidget {
  const RosaryScreen({Key? key}) : super(key: key);

  @override
  State<RosaryScreen> createState() => _RosaryScreenState();
}

class _RosaryScreenState extends State<RosaryScreen> {
  // Référence au service audio
  late AudioPlayerService audioService;

  // Liste des images pour chaque mystère
  final List<String> mysteryImages = [
    Assets.imagesJoyeux, // Mystères Joyeux
    Assets.imagesLumineux, // Mystères Lumineux
    Assets.imagesDouloureux, // Mystères Douloureux
    Assets.imagesGlorieux, // Mystères Glorieux
  ];

  @override
  void initState() {
    super.initState();

    // Obtenir le service audio
    audioService = AudioPlayerService.to;

    // Charger l'audio initial si nécessaire
    if (!audioService.showMiniPlayer.value) {
      // Utiliser le mystère correspondant au jour actuel
      final mysteryIndex = audioService.getMysteryIndexForCurrentDay();
      audioService.loadAudio(mysteryIndex, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RosaryController>(
      builder: (controller) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 0,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current mystery info
                    _buildMysteryInfoCard(controller),

                    // Information sur le jour actuel
                    const SizedBox(height: 24),
                    _buildDailyInfo(),

                    const SizedBox(height: 20),

                    // Affichage dynamique avec animation de l'image du mystère sélectionné
                    _buildMysteryImage(),

                    const SizedBox(height: 20),

                    // WAVE
                    _buildWaveform(controller),

                    //const SizedBox(height: 20),

                    // Audio progress avec boutons avance/recul rapide
                    _buildAudioProgressBar(controller),

                    // Espace supplémentaire en bas pour éviter que le bouton flottant ne cache du contenu
                    const SizedBox(height: 0),
                  ],
                ),
              ),
            ),

            // Bouton de lecture/pause flottant
            Positioned(
              bottom: 25,
              right: 0,
              left: 0,
              child: _buildFloatingPlayButton(),
            ),
          ],
        );
      },
    );
  }

  // Card d'information sur le mystère actuel
  Widget _buildMysteryInfoCard(RosaryController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          // Current Mystery Title
          Text(
            'Méditation des mystères',
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.sixteen,
              textColor: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Menu déroulant pour choisir le mystère
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorGreenSemiLight, width: 1),
            ),
            child: DropdownButton<int>(
              value: audioService.currentMystereIndex.value,
              icon: const Icon(Icons.arrow_drop_down, color: colorGreenSemiLight),
              elevation: 10,
              underline: Container(height: 0),
              style: TextStyles.montserratBold(
                textSize: TextSizes.eighteen,
                textColor: colorGreenSemiLight,
              ),
              dropdownColor: Colors.white,
             enableFeedback: true,
              isExpanded: true,
              isDense: false,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  audioService.loadAudio(newValue, 0);
                }
              },
              items: audioService.mysteres.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  alignment: Alignment.center,
                  child: Text(
                    entry.value,
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.eighteen,
                      textColor: colorGreenSemiLight,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Afficher l'indicateur de streaming si actif
          if (audioService.isStreamingMode.value)
            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorGreenSemiLight.withValues(alpha: 0.1),
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
                        valueColor: AlwaysStoppedAnimation<Color>(colorGreenSemiLight),
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
                        audioService.currentMystereDetailIndex.value);
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
    );
  }

  // Widget pour l'image du mystère
  Widget _buildMysteryImage() {
    return Obx(() {
      final currentImage = mysteryImages[audioService.currentMystereIndex.value];
      return SlideTransitionImageDisplayer(icon: currentImage);
    });
  }

  // Widget pour le waveform audio
  Widget _buildWaveform(RosaryController controller) {
    return Obx(() {
      final waveformBytes = audioService.waveformData.value;

      // Si aucune donnée waveform n'est disponible mais qu'on est en chargement
      if (waveformBytes == null) {
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[100],
          ),
          child: audioService.isWaveformLoading.value
              ? AnimatedPlaceholderWaveform(
            activeColor: _getWaveformActiveColor(controller.currentColorTheme.value)
                .withValues(alpha: 0.3),
            inactiveColor: _getWaveformInactiveColor(controller.currentColorTheme.value)
                .withValues(alpha: 0.1),
          )
              : const SizedBox(), // Espace vide si pas en chargement et pas de données
        );
      }

      // Si on a des données waveform, on les affiche
      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
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

              return CustomPaint(
                size: const Size(double.infinity, 40),
                painter: WaveformPainter(
                  waveform: waveformBytes,
                  progress: progress,
                  activeColor: _getWaveformActiveColor(controller.currentColorTheme.value),
                  inactiveColor: _getWaveformInactiveColor(controller.currentColorTheme.value),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  // Widget pour la barre de progression audio avec boutons d'avance/recul
  Widget _buildAudioProgressBar(RosaryController controller) {
    return Row(
      children: [
        // Bouton de recul de 10s
        _buildSecondaryButton(
          icon: Icons.replay_10,
          onPressed: () {
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

        // Barre de progression
        Expanded(
          child: StreamBuilder<PositionData>(
              stream: audioService.positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(
                      position: Duration.zero,
                      bufferedPosition: Duration.zero,
                      duration: Duration.zero,
                    );

                return Obx(() {
                  return IgnorePointer(
                    ignoring: audioService.isLoadingAudio.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ProgressBar(
                        progress: positionData.position,
                        buffered: positionData.bufferedPosition,
                        total: positionData.duration,
                        progressBarColor: RosaryTheme.getTheme(
                            controller.currentColorTheme.value)
                            .activeColor,
                        baseBarColor: Colors.grey[100],
                        bufferedBarColor: RosaryTheme.getTheme(
                            controller.currentColorTheme.value)
                            .inactiveColor
                            .withValues(alpha: 0.6),
                        thumbColor: RosaryTheme.getTheme(
                            controller.currentColorTheme.value)
                            .activeColor,
                        barHeight: 6.0,
                        thumbRadius: 8.0,
                        timeLabelType: TimeLabelType.remainingTime,
                        timeLabelTextStyle: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen,
                          textColor: Colors.grey[700]!,
                        ),
                        timeLabelPadding: 8.0,
                        onSeek: (duration) {
                          audioService.audioPlayer.seek(duration);
                        },
                      ),
                    ),
                  );
                });
              }
          ),
        ),

        // Bouton d'avance de 10s
        _buildSecondaryButton(
          icon: Icons.forward_10,
          onPressed: () {
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
      ],
    );
  }

  // Widget pour le bouton de lecture/pause flottant
  Widget _buildFloatingPlayButton() {
    return Center(
      child: Obx(() {
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorGreenSemiLight,
            boxShadow: [
              BoxShadow(
                color: colorGreenSemiLight.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(35),
              onTap: () => audioService.playPause(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  audioService.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  key: ValueKey<bool>(audioService.isPlaying.value),
                  size: 42,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Widget pour l'information sur le jour actuel
  Widget _buildDailyInfo() {
    final currentDay = audioService.getCurrentDayName();
    final suggestedMysteryIndex = audioService.getMysteryIndexForCurrentDay();

    if (suggestedMysteryIndex < audioService.mysteres.length) {
      final suggestedMystery = audioService.mysteres[suggestedMysteryIndex];

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          'Aujourd\'hui $currentDay : Mystères $suggestedMystery',
          style: TextStyles.montserratRegular(
            textSize: TextSizes.twelve,
            textColor: Colors.grey[600]!,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Méthode pour obtenir les couleurs appropriées selon le thème
  Color _getWaveformActiveColor(RosaryColorTheme theme) {
    final rosaryTheme = RosaryTheme.getTheme(theme);
    return rosaryTheme.activeColor.withValues(alpha: 0.75);
  }

  Color _getWaveformInactiveColor(RosaryColorTheme theme) {
    final rosaryTheme = RosaryTheme.getTheme(theme);
    return rosaryTheme.inactiveColor;
  }

  // Widget pour les boutons secondaires
  Widget _buildSecondaryButton({
    required IconData icon,
    required VoidCallback onPressed,
    Function()? onLongPress,
    Function(LongPressEndDetails)? onLongPressEnd,
  }) {
    return Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: onPressed,
        onLongPress: onLongPress,
        onLongPressEnd: onLongPressEnd,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: colorGreenSemiLight,
            size: 24,
          ),
        ),
      ),
    );
  }
}
