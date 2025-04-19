import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/mini_player.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/commons/constants.dart';

class MainAppWrapper extends StatelessWidget {
  final Widget child;

  const MainAppWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  // Vérifier si nous sommes sur l'écran Rosaire
  bool _isOnRosaryScreen() {
    try {
      final customHomeController = Get.find<CustomHomeController>();
      return customHomeController.menus[customHomeController.selectedIndex.value].code == AppConstants.ROSAIRE;
    } catch (e) {
      // En cas d'erreur, on suppose qu'on n'est pas sur l'écran rosaire
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir le service audio
    final audioService = Get.isRegistered<AudioPlayerService>() ? Get.find<AudioPlayerService>() : Get.put<AudioPlayerService>(AudioPlayerService(), permanent: true);

    return Scaffold(
      body: Column(
        children: [
          // Contenu principal de l'application
          Expanded(child: child),

          // Mini lecteur - visible uniquement si showMiniPlayer est true ET qu'on n'est pas sur l'écran Rosaire
          Obx(() {
            // Vérifier les deux conditions
            bool isRosaryScreen = _isOnRosaryScreen();
            bool shouldShowPlayer = audioService.showMiniPlayer.value && !isRosaryScreen;

            if (shouldShowPlayer) {
              return const MiniPlayer();
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}