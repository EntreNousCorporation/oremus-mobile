import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';


/// Fabrique pour gérer les instances de RefreshController
/// Évite le problème d'utilisation d'un même contrôleur pour plusieurs SmartRefresher
class RefreshControllerFactory {
  /// Cache des contrôleurs par identifiant
  static final Map<String, RefreshController> _controllers = {};

  /// Obtient un contrôleur existant ou en crée un nouveau pour l'identifiant donné
  static RefreshController getController(String id) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = RefreshController(initialRefresh: false);
    }
    return _controllers[id]!;
  }

  /// Libère les ressources d'un contrôleur spécifique
  static void disposeController(String id) {
    if (_controllers.containsKey(id)) {
      _controllers[id]!.dispose();
      _controllers.remove(id);
    }
  }

  /// Libère les ressources de tous les contrôleurs
  static void disposeAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}
