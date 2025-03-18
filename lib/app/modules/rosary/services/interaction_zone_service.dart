import 'dart:async';
import 'package:get/get.dart';

/// Service pour gérer les zones d'interaction critiques dans l'application
/// et optimiser le positionnement des composants flottants comme le mini-lecteur
class InteractionZoneService extends GetxService {
  static InteractionZoneService get to => Get.find<InteractionZoneService>();

  // Position actuelle du lecteur (réactive)
  final isPositionedAtTop = RxBool(false);

  // État du verrouillage de position
  final isPositionLocked = RxBool(false);

  // Route actuelle pour la surveillance
  final currentRoute = ''.obs;

  // Timer pour la vérification de route
  StreamSubscription? _routeSubscription;

  // Map des routes vers leur configuration spécifique
  final Map<String, RouteConfig> routeConfigurations = {
    '/signin': RouteConfig(avoidBottom: true, bottomSafeAreaHeight: 180, allowDrag: true),
    '/signup': RouteConfig(avoidBottom: true, bottomSafeAreaHeight: 200, allowDrag: true),
    '/paroisse-messe': RouteConfig(avoidBottom: true, bottomSafeAreaHeight: 100, allowDrag: true),
    '/reset-password': RouteConfig(avoidBottom: true, bottomSafeAreaHeight: 150, allowDrag: true),
    '/check-otp': RouteConfig(avoidBottom: true, bottomSafeAreaHeight: 180, allowDrag: true),
    '/init-reset-password': RouteConfig(avoidBottom: true, bottomSafeAreaHeight: 180, allowDrag: true),
    // Ajoutez ici d'autres routes nécessitant une configuration spéciale
  };

  // Routes où le mini-lecteur doit être en position fixe en haut
  final List<String> forceTopRoutes = [
    '/signin',
    '/signup',
    '/init-reset-password',
    '/check-otp',
    '/reset-password',
    '/paroisse-messe',
  ];

  // Routes où le mini-lecteur doit être masqué complètement
  final List<String> hidePlayerRoutes = [
    // Ajoutez ici des routes où le lecteur devrait être complètement caché
  ];

  @override
  void onInit() {
    super.onInit();

    // Configurer la route initiale
    currentRoute.value = Get.currentRoute;

    // Surveiller les changements de route pour réinitialiser le positionnement
    ever(currentRoute, (_) {
      updatePositionForCurrentRoute();
    });

    // Mettre en place un écouteur pour les changements de route
    _setupRouteObserver();

    // Configurer la position initiale
    updatePositionForCurrentRoute();
  }

  // Configurer l'observateur de route
  void _setupRouteObserver() {
    // Utiliser une méthode plus sûre pour surveiller les changements de route
    try {
      // Vérifier périodiquement si la route a changé
      Future.delayed(const Duration(milliseconds: 300), () {
        _routeSubscription =
            Stream.periodic(const Duration(milliseconds: 300), (_) => Get.currentRoute)
                .listen((route) {
              if (route != currentRoute.value) {
                currentRoute.value = route;
              }
            });
      });
    } catch (e) {
      print("Erreur lors de la mise en place de l'observateur de route: $e");
    }
  }

  // Mettre à jour la position en fonction de la route actuelle
  void updatePositionForCurrentRoute() {
    final route = currentRoute.value;

    // Par défaut, déverrouiller la position (permettre le déplacement)
    isPositionLocked.value = false;

    // Vérifier si cette route a une position forcée
    if (forceTopRoutes.contains(route)) {
      isPositionedAtTop.value = true;

      // Vérifier si le déplacement est autorisé pour cette route
      final config = routeConfigurations[route];
      isPositionLocked.value = config?.allowDrag != true;
    } else {
      // Pour les autres routes, positionner en bas par défaut
      isPositionedAtTop.value = false;
    }
  }

  // Vérifier si le lecteur doit être positionné en haut pour la route actuelle
  bool shouldPositionAtTop(String route) {
    return isPositionedAtTop.value;
  }

  // Modifier la position manuellement (via glissement)
  void togglePosition() {
    if (!isPositionLocked.value) {
      isPositionedAtTop.value = !isPositionedAtTop.value;
    }
  }

  // Déplacer vers le haut
  void moveToTop() {
    if (!isPositionLocked.value) {
      isPositionedAtTop.value = true;
    }
  }

  // Déplacer vers le bas
  void moveToBottom() {
    if (!isPositionLocked.value) {
      isPositionedAtTop.value = false;
    }
  }

  // Vérifier si le lecteur doit être caché pour la route actuelle
  bool shouldHidePlayer(String route) {
    return hidePlayerRoutes.contains(route);
  }

  // Obtenir la hauteur sécurisée pour le bas de l'écran
  double getBottomSafeArea(String route, double defaultHeight) {
    final config = routeConfigurations[route];
    return config?.bottomSafeAreaHeight ?? defaultHeight;
  }

  // Vérifier si le déplacement est autorisé pour la route actuelle
  bool isDraggingAllowed(String route) {
    return !isPositionLocked.value;
  }

  @override
  void onClose() {
    // Nettoyer la souscription lors de la fermeture du service
    _routeSubscription?.cancel();
    super.onClose();
  }
}

/// Configuration pour une route spécifique
class RouteConfig {
  final bool avoidBottom;
  final double bottomSafeAreaHeight;
  final bool allowDrag;  // Nouvel attribut pour permettre le déplacement

  RouteConfig({
    this.avoidBottom = false,
    this.bottomSafeAreaHeight = 100,
    this.allowDrag = false,  // Par défaut, ne pas permettre le déplacement
  });
}
