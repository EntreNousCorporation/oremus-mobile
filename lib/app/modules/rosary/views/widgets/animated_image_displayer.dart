import 'dart:math' as math;
import 'package:flutter/material.dart';

// 1. Animation de transition par glissement latéral
class SlideTransitionImageDisplayer extends StatefulWidget {
  final String icon;
  final Duration animationDuration;

  const SlideTransitionImageDisplayer({
    Key? key,
    required this.icon,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<SlideTransitionImageDisplayer> createState() => _SlideTransitionImageDisplayerState();
}

class _SlideTransitionImageDisplayerState extends State<SlideTransitionImageDisplayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  String _currentIcon = '';
  String _nextIcon = '';
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.icon;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(SlideTransitionImageDisplayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.icon != widget.icon) {
      _nextIcon = widget.icon;
      _isForward = !_isForward;
      _slideAnimation = Tween<Offset>(
        begin: Offset(_isForward ? 1.0 : -1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _startTransition();
    }
  }

  void _startTransition() {
    _controller.reset();
    setState(() {
      _currentIcon = _nextIcon;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.asset(
                  _currentIcon,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 2. Animation avec rotation 3D
class Rotation3DImageDisplayer extends StatefulWidget {
  final String icon;
  final Duration animationDuration;

  const Rotation3DImageDisplayer({
    Key? key,
    required this.icon,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<Rotation3DImageDisplayer> createState() => _Rotation3DImageDisplayerState();
}

class _Rotation3DImageDisplayerState extends State<Rotation3DImageDisplayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  String _currentIcon = '';
  String _nextIcon = '';

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.icon;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    // Démarrer l'animation initiale avec un léger délai
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void didUpdateWidget(Rotation3DImageDisplayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.icon != widget.icon) {
      _nextIcon = widget.icon;
      _startTransition();
    }
  }

  void _startTransition() {
    // Réinitialiser pour l'animation de sortie
    _controller.reset();

    // Animation complète (rotation de 180°)
    _controller.forward().then((_) {
      setState(() {
        _currentIcon = _nextIcon;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Première moitié de l'animation: rotation de l'image actuelle
        // Deuxième moitié: rotation de la nouvelle image
        final showFrontSide = _rotationAnimation.value <= 0.5;
        final animationValue = showFrontSide
            ? _rotationAnimation.value * 2  // 0 -> 1 pour la première moitié
            : (_rotationAnimation.value - 0.5) * 2; // 0 -> 1 pour la deuxième moitié

        final rotationValue = showFrontSide
            ? animationValue * math.pi / 2  // Rotation de 0 à 90 degrés
            : math.pi - (animationValue * math.pi / 2); // Rotation de 180 à 90 degrés

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(rotationValue),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                showFrontSide || _rotationAnimation.value <= 0.5 ? _currentIcon : _nextIcon,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

// 3. Animation avec effet de halo lumineux
class GlowingBorderImageDisplayer extends StatefulWidget {
  final String icon;
  final Duration animationDuration;
  final Color glowColor;

  const GlowingBorderImageDisplayer({
    Key? key,
    required this.icon,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.glowColor = const Color(0xFF4CAF50),
  }) : super(key: key);

  @override
  State<GlowingBorderImageDisplayer> createState() => _GlowingBorderImageDisplayerState();
}

class _GlowingBorderImageDisplayerState extends State<GlowingBorderImageDisplayer>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  String _currentIcon = '';
  String _nextIcon = '';

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.icon;

    // Contrôleur pour les transitions entre images
    _transitionController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Contrôleur pour l'effet de pulsation du halo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Démarrer les animations
    _transitionController.forward();
  }

  @override
  void didUpdateWidget(GlowingBorderImageDisplayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.icon != widget.icon) {
      _nextIcon = widget.icon;
      _startTransition();
    }
  }

  void _startTransition() {
    _transitionController.reset();
    _transitionController.forward().then((_) {
      setState(() {
        _currentIcon = _nextIcon;
      });
    });
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_transitionController, _pulseController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: 0.1 + (_glowAnimation.value * 0.2)),
                blurRadius: 10 + (_glowAnimation.value * 15),
                spreadRadius: 2 + (_glowAnimation.value * 3),
              ),
            ],
          ),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: widget.glowColor.withValues(alpha: 0.4 + (_glowAnimation.value * 0.4)),
                    width: 1.5 + (_glowAnimation.value * 1.0),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    _currentIcon,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 4. Animation avec effet de page qui se tourne
class PageTurnImageDisplayer extends StatefulWidget {
  final String icon;
  final Duration animationDuration;

  const PageTurnImageDisplayer({
    Key? key,
    required this.icon,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<PageTurnImageDisplayer> createState() => _PageTurnImageDisplayerState();
}

class _PageTurnImageDisplayerState extends State<PageTurnImageDisplayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _currentIcon = '';
  String _nextIcon = '';

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.icon;
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    // Animation initiale
    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.forward(from: 0.0);
    });
  }

  @override
  void didUpdateWidget(PageTurnImageDisplayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.icon != widget.icon) {
      _nextIcon = widget.icon;
      _startTransition();
    }
  }

  void _startTransition() {
    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _currentIcon = _nextIcon;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculer l'angle de rotation
        final angle = (_animation.value * math.pi / 2);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Image actuelle
                Opacity(
                  opacity: 1.0 - _animation.value,
                  child: Image.asset(
                    _currentIcon,
                    fit: BoxFit.cover,
                  ),
                ),

                // Animation de "page qui se tourne"
                Positioned.fill(
                  child: Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-angle),
                    child: Opacity(
                      opacity: _animation.value < 0.5 ? 0 : 1,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: Image.asset(
                          _nextIcon.isEmpty ? _currentIcon : _nextIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                // Ombre de la page qui se tourne
                if (_animation.value > 0.0 && _animation.value < 1.0)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: _animation.value < 0.5
                        ? MediaQuery.of(context).size.width * (1 - _animation.value * 2)
                        : 0,
                    width: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 3,
                            offset: const Offset(-5, 0),
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
