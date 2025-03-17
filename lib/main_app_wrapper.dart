import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosaire/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosaire/services/interaction_zone_service.dart';
import 'package:oremusapp/app/modules/rosaire/views/widgets/mini_player_widget.dart';

/// Un wrapper pour afficher le mini-lecteur au-dessus de toutes les pages de l'application
class MainAppWrapper extends StatefulWidget {
  final Widget child;

  const MainAppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> with WidgetsBindingObserver {
  late AudioPlayerService audioService;
  late InteractionZoneService zoneService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialiser les services
    audioService = Get.find<AudioPlayerService>();
    zoneService = Get.find<InteractionZoneService>();

    // S'assurer que la route actuelle est bien initialisée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      zoneService.currentRoute.value = Get.currentRoute;
      zoneService.updatePositionForCurrentRoute();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si l'application reprend du premier plan, mettre à jour la route
    if (state == AppLifecycleState.resumed) {
      zoneService.currentRoute.value = Get.currentRoute;
      zoneService.updatePositionForCurrentRoute();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Le contenu principal de l'application
          widget.child,

          // Le mini-lecteur avec positionnement intelligent
          MiniPlayerWidget(),
        ],
      ),
    );
  }
}