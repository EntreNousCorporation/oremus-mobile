import 'dart:io';

import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:path_provider/path_provider.dart';

/// Utilitaire pour gérer les différences de stockage entre iOS et Android
class PlatformFileHelper {
  /// Obtient le répertoire de stockage approprié selon la plateforme
  static Future<Directory> getStorageDirectory() async {
    if (Platform.isIOS) {
      // Sur iOS, il est préférable d'utiliser le répertoire de documents permanent
      // car les fichiers dans le répertoire temporaire peuvent être supprimés par le système
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      // Sur Android, nous pouvons utiliser le répertoire de l'application
      return await getApplicationDocumentsDirectory();
    }

    // Par défaut, retourner le répertoire de documents
    return await getApplicationDocumentsDirectory();
  }

  /// Vérifie de manière robuste si un fichier existe
  static Future<bool> fileExists(String path) async {
    try {
      final file = File(path);
      final exists = await file.exists();
      final size = exists ? await file.length() : 0;
      OremusLogger.debug('Vérification du fichier: $path, existe: $exists, taille: $size octets');
      return exists && size > 0; // S'assurer que le fichier n'est pas vide
    } catch (e) {
      OremusLogger.error('Erreur lors de la vérification du fichier: $e');
      return false;
    }
  }

  /// Crée un répertoire s'il n'existe pas, avec un traitement spécial pour iOS
  static Future<Directory> ensureDirectoryExists(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      if (await directory.exists()) {
        return directory;
      }

      // Créer le répertoire avec des paramètres spéciaux sur iOS
      if (Platform.isIOS) {
        // Sur iOS, nous devons parfois créer le répertoire avec des permissions spécifiques
        return await directory.create(recursive: true);
      } else {
        return await directory.create(recursive: true);
      }
    } catch (e) {
      OremusLogger.error('Erreur lors de la création du répertoire: $e');
      // En cas d'échec, essayer d'utiliser un répertoire temporaire
      final tempDir = await getTemporaryDirectory();
      final fallbackDir = Directory('${tempDir.path}/rosary_audio');
      return await fallbackDir.create(recursive: true);
    }
  }
}
