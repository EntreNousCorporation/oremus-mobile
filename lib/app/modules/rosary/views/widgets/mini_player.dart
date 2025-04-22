import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/modules/rosary/controller/rosary_controller.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/painters/rosary_painter_variant.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/miniplayers/artistique_player.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/miniplayers/classic_player.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/miniplayers/elegant_player.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/miniplayers/minimalist_player.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/miniplayers/modern_player.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/miniplayers/prestigieux_player.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = AudioPlayerService.to;

    // Obtenir le contrôleur du chapelet pour accéder au style et thème actuels
    final RosaryController rosaryController = Get.find<RosaryController>();

    // Construire le mini player selon le style sélectionné
    switch (rosaryController.currentStyle.value) {
      case RosaryStyle.elegant:
        return ElegantPlayer(audioService: audioService, controller: rosaryController);
      case RosaryStyle.minimalist:
        return MinimalistPlayer(audioService: audioService, controller: rosaryController);
      case RosaryStyle.modern:
        return ModernPlayer(audioService: audioService, controller: rosaryController);
      case RosaryStyle.artistique:
        return ArtistiquePlayer(audioService: audioService, controller: rosaryController);
      case RosaryStyle.prestigieux:
        return PrestigieuxPlayer(audioService: audioService, controller: rosaryController);
      case RosaryStyle.classic:
      default:
        return ClassicPlayer(audioService: audioService, controller: rosaryController);
    }
  }
}
