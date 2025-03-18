import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/services/interaction_zone_service.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService.to;
    final zoneService = Get.find<InteractionZoneService>();
    final currentRoute = Get.currentRoute;
    final mediaQuery = MediaQuery.of(context);

    // Vérifier si le lecteur doit être caché complètement
    if (zoneService.shouldHidePlayer(currentRoute)) {
      return const SizedBox.shrink();
    }

    // Calculer les marges par défaut
    final defaultTopMargin = mediaQuery.padding.top + 10.0;
    final defaultBottomMargin = mediaQuery.padding.bottom + 10.0;

    return Obx(() {
      // Si le mini-lecteur n'est pas visible, ne rien afficher
      if (!audioService.showMiniPlayer.value) {
        return const SizedBox.shrink();
      }

      // Déterminer la position du lecteur (en haut ou en bas)
      final bool positionAtTop = zoneService.isPositionedAtTop.value;

      // Déterminer si le déplacement par glissement est autorisé
      final bool canDrag = zoneService.isDraggingAllowed(currentRoute);

      // Calcul de la hauteur disponible pour éviter les zones d'interaction
      final keyboardHeight = mediaQuery.viewInsets.bottom;
      final isKeyboardVisible = keyboardHeight > 0;

      // Si le clavier est visible et que le lecteur est en bas, déplacer vers le haut
      if (isKeyboardVisible && !positionAtTop) {
        // Utiliser Future.microtask pour éviter de modifier l'état pendant le build
        Future.microtask(() => zoneService.moveToTop());
      }

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        top: positionAtTop ? defaultTopMargin : null,
        bottom: positionAtTop ? null : defaultBottomMargin,
        left: 16,
        right: 16,
        child: GestureDetector(
          // Permet de glisser le mini-lecteur entre haut et bas de l'écran si autorisé
          onVerticalDragEnd: canDrag ? (details) {
            // Si glissé vers le haut avec une certaine vitesse, placer en haut
            if (details.velocity.pixelsPerSecond.dy < -300 && !positionAtTop) {
              zoneService.moveToTop();
            }
            // Si glissé vers le bas avec une certaine vitesse, placer en bas
            else if (details.velocity.pixelsPerSecond.dy > 300 && positionAtTop) {
              zoneService.moveToBottom();
            }
          } : null,
          // Permet également de basculer la position en tapant deux fois
          onDoubleTap: canDrag ? () {
            zoneService.togglePosition();
          } : null,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(32),
            color: Colors.transparent,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colorGreenSemiLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Barre de progression en arrière-plan
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
                      final progress = positionData.duration.inMilliseconds > 0
                          ? positionData.position.inMilliseconds / positionData.duration.inMilliseconds
                          : 0.0;

                      return Row(
                        children: [
                          Expanded(
                            flex: (progress * 100).toInt(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorGreenSemiLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.horizontal(left: const Radius.circular(32), right: Radius.circular(progress >= 1.0 ? 32 : 0)),
                              ),
                            ),
                          ),
                          if (progress < 1.0)
                            Expanded(
                              flex: (100 - progress * 100).toInt(),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // Indicateur de déplacement (affiché uniquement si le déplacement est autorisé)
                  if (canDrag)
                    Positioned(
                      top: 3,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    ),

                  // Contenu du mini-lecteur
                  Row(
                    children: [
                      // Titre mystère en cours
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                audioService.currentMystereTitle.value,
                                style: TextStyles.montserratSemiBold(
                                  textSize: TextSizes.thirteen,
                                  textColor: colorGreenSemiLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                audioService.currentMystereDetailTitle.value,
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.twelve,
                                  textColor: Colors.grey[700]!,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Boutons de contrôle
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton précédent
                          IconButton(
                            icon: const Icon(
                              Icons.skip_previous_rounded,
                              color: colorGreenSemiLight,
                              size: 24,
                            ),
                            onPressed: audioService.navigateToPreviousMystery,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),

                          // Bouton lecture/pause
                          IconButton(
                            icon: Icon(
                              audioService.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: colorGreenSemiLight,
                              size: 28,
                            ),
                            onPressed: audioService.playPause,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),

                          // Bouton suivant
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next_rounded,
                              color: colorGreenSemiLight,
                              size: 24,
                            ),
                            onPressed: audioService.navigateToNextMystery,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),

                          // Bouton fermer
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey[400],
                              size: 18,
                            ),
                            onPressed: audioService.closeMiniPlayer,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
