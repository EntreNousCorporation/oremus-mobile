import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';

class SpeedControlWidget extends StatelessWidget {
  final AudioPlayerService audioService = AudioPlayerService.to;

  SpeedControlWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => _showSpeedBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: audioService.playbackSpeed.value != 1.0
              ? colorGreenSemiLight
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorGreenSemiLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              size: 16,
              color: audioService.playbackSpeed.value != 1.0
                  ? Colors.white
                  : colorGreenSemiLight,
            ),
            const SizedBox(width: 4),
            Text(
              '${audioService.playbackSpeed.value}x',
              style: TextStyles.montserratSemiBold(
                textSize: TextSizes.fourteen,
                textColor: audioService.playbackSpeed.value != 1.0
                    ? Colors.white
                    : colorGreenSemiLight,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _showSpeedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicateur de poignée
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            Text(
              'Vitesse de lecture',
              style: TextStyles.montserratBold(
                textSize: TextSizes.eighteen,
                textColor: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Options de vitesse
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: audioService.speedOptions.map((speed) {
                return Obx(() => _buildSpeedOption(speed));
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Bouton de réinitialisation
            if (audioService.playbackSpeed.value != 1.0)
              TextButton(
                onPressed: () {
                  audioService.resetToNormalSpeed();
                  Navigator.pop(context);
                },
                child: Text(
                  'Réinitialiser à la normale',
                  style: TextStyles.montserratRegular(
                    textSize: TextSizes.fourteen,
                    textColor: Colors.grey[600]!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedOption(double speed) {
    final isSelected = audioService.playbackSpeed.value == speed;

    return GestureDetector(
      onTap: () {
        audioService.setPlaybackSpeed(speed);
      },
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? colorGreenSemiLight : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorGreenSemiLight : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '${speed}x',
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fourteen,
              textColor: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
