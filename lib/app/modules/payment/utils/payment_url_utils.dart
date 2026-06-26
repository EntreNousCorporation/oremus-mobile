/// Helpers pour identifier et parser les URLs interceptées dans la WebView
/// de paiement (CinetPay → Wave).
///
/// Extrait du `PaymentController` pour pouvoir tester unitairement les règles
/// de routing externe : c'est historiquement la zone la plus sensible du
/// flux de paiement (cf. commit `Fix wave redirection payment`).
class PaymentUrlUtils {
  PaymentUrlUtils._();

  /// `true` si l'URL doit être ouverte par une app externe (Wave) plutôt
  /// que de continuer la navigation dans la WebView CinetPay.
  static bool isExternalAppUrl(String url) {
    return url.contains('wave.com') || url.startsWith('wave://');
  }

  /// Pour une URL Wave de la forme `https://pay.wave.com/c/{id}/capture/{rest}`,
  /// renvoie la portion `{rest}` à passer à `launchUrl`. Retourne l'URL
  /// d'entrée inchangée si le marqueur `capture/` est absent.
  static String extractWaveCaptureUrl(String url) {
    return url.split('capture/').last;
  }
}
