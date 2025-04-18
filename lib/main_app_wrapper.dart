import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/mini_player.dart';

/// Un wrapper pour afficher le mini-lecteur au-dessus de toutes les pages de l'application
class MainAppWrapper extends StatefulWidget {
  final Widget child;

  const MainAppWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  late AudioPlayerService audioService;

  @override
  void initState() {
    super.initState();
    // Initialiser les services
    audioService = Get.find<AudioPlayerService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal de l'application prend tout l'espace
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.child,
          ),

          // Mini lecteur positionné en bas
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }
}