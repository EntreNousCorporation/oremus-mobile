import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_player_service.dart';
import 'package:oremusapp/app/modules/rosary/views/widgets/mini_player.dart';
import 'package:oremusapp/app/modules/customhome/controller/custom_home_controller.dart';
import 'package:oremusapp/app/commons/constants.dart';

class MainAppWrapper extends StatefulWidget {
  final Widget child;

  const MainAppWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> with SingleTickerProviderStateMixin {
  // Contrôleur d'animation
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animation de glissement du bas vers le haut
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),  // Position initiale (hors écran)
      end: Offset.zero,           // Position finale (visible)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,  // Courbe d'accélération pour un effet naturel
      reverseCurve: Curves.easeInQuart,
    ));

    // Écouter les changements d'état du mini-lecteur
    _setupListeners();
  }

  void _setupListeners() {
    // Obtenir le service audio
    final audioService = Get.isRegistered<AudioPlayerService>()
        ? Get.find<AudioPlayerService>()
        : Get.put<AudioPlayerService>(AudioPlayerService(), permanent: true);

    // À chaque changement de l'état du mini-lecteur, mettre à jour l'animation
    ever(audioService.showMiniPlayer, (bool show) {
      _updateAnimationState(show);
    });
  }

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

  // Mettre à jour l'état de l'animation
  void _updateAnimationState(bool show) {
    bool isRosaryScreen = _isOnRosaryScreen();
    bool shouldShow = show && !isRosaryScreen;

    if (shouldShow && !_isVisible) {
      _animationController.forward();
      _isVisible = true;
    } else if (!shouldShow && _isVisible) {
      _animationController.reverse();
      _isVisible = false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir le service audio
    final audioService = Get.isRegistered<AudioPlayerService>()
        ? Get.find<AudioPlayerService>()
        : Get.put<AudioPlayerService>(AudioPlayerService(), permanent: true);

    return Scaffold(
      body: Column(
        children: [
          // Contenu principal de l'application
          Expanded(child: widget.child),

          // Mini lecteur avec animation
          Obx(() {
            bool isRosaryScreen = _isOnRosaryScreen();
            bool shouldShowPlayer = audioService.showMiniPlayer.value && !isRosaryScreen;

            // Mettre à jour l'état de l'animation si nécessaire
            if (_isVisible != shouldShowPlayer) {
              _updateAnimationState(audioService.showMiniPlayer.value);
            }

            return ClipRect(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _animationController,
                  child: shouldShowPlayer || _isVisible
                      ? const MiniPlayer()
                      : const SizedBox.shrink(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
