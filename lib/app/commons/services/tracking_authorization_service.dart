import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';

/// Demande l'autorisation de suivi (ATT) sur iOS. Sans elle, l'IDFA reste à
/// zéro et Google Ads ne peut attribuer les installations que via
/// SKAdNetwork (mesure agrégée, sans détail par utilisateur).
class TrackingAuthorizationService {
  /// iOS ignore la demande tant que l'app n'est pas réellement affichée :
  /// le dialogue ne s'ouvre pas et le statut reste `notDetermined`.
  static const _uiSettleDelay = Duration(milliseconds: 500);

  static Future<void> requestIfNeeded() async {
    if (!Platform.isIOS) return;

    try {
      final currentStatus =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (currentStatus != TrackingStatus.notDetermined) {
        OremusLogger.info('ATT déjà résolu => $currentStatus');
        return;
      }

      await Future.delayed(_uiSettleDelay);
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      OremusLogger.info('ATT demandé => $status');
    } catch (ex) {
      OremusLogger.error('ATT => ${ex.toString()}');
    }
  }
}
