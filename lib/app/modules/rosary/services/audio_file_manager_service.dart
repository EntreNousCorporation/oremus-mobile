import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/rosary/data/model/rosary_file_data.dart';

/// Service qui gère le téléchargement et la mise en cache des fichiers audio pour le rosaire
class AudioFileManagerService extends GetxService {
  static AudioFileManagerService get to => Get.find<AudioFileManagerService>();

  // URL pour l'API du rosaire
  final String baseUrl = 'https://api-dev.oremus.ci/rosaries';

  // Map des index de mystère et détail vers les chemins de fichiers téléchargés
  final _downloadedFiles = <String, String>{}.obs;

  // Suivi de la progression du téléchargement
  final downloadProgress = 0.0.obs;
  final isDownloading = false.obs;
  final currentlyDownloadingKey = ''.obs;

  // Clé pour stocker les fichiers téléchargés dans la BD
  static const String KEY_DOWNLOADED_FILES = 'downloaded_rosary_files';

  @override
  void onInit() {
    super.onInit();
    _loadCachedFilePaths();
  }

  /// Charger les chemins de fichiers mis en cache depuis la BD
  void _loadCachedFilePaths() {
    try {
      String? cachedData = DB.getData(KEY_DOWNLOADED_FILES);
      if (cachedData != null && cachedData.isNotEmpty) {
        Map<String, dynamic> data = json.decode(cachedData);
        data.forEach((key, value) {
          // Vérifier que le fichier existe avant de l'ajouter à la map
          if (File(value).existsSync()) {
            _downloadedFiles[key] = value;
          } else {
            log('Fichier en cache non trouvé: $value');
          }
        });
      }
      log('Chargé ${_downloadedFiles.length} chemins de fichiers en cache');
    } catch (e) {
      log('Erreur lors du chargement des chemins de fichiers en cache: $e');
    }
  }

  /// Sauvegarder les chemins de fichiers téléchargés dans la BD
  void _saveCachedFilePaths() {
    try {
      DB.saveData(KEY_DOWNLOADED_FILES, json.encode(_downloadedFiles));
    } catch (e) {
      log('Erreur lors de la sauvegarde des chemins de fichiers en cache: $e');
    }
  }

  /// Vérifier si le fichier est déjà téléchargé
  bool isFileDownloaded(int mystereIndex, int detailIndex) {
    String key = _getKey(mystereIndex, detailIndex);
    return _downloadedFiles.containsKey(key);
  }

  /// Obtenir le chemin du fichier local s'il est téléchargé, null sinon
  String? getLocalFilePath(int mystereIndex, int detailIndex) {
    String key = _getKey(mystereIndex, detailIndex);
    return _downloadedFiles[key];
  }

  /// Obtenir la clé pour le mystère
  String _getKey(int mystereIndex, int detailIndex) {
    return '$mystereIndex-$detailIndex';
  }

  /// Télécharger le fichier audio pour un mystère spécifique
  /// Retourne le chemin du fichier une fois téléchargé
  Future<String?> downloadFile(int mystereIndex, int detailIndex) async {
    String key = _getKey(mystereIndex, detailIndex);

    // Vérifier si le fichier est déjà téléchargé
    if (_downloadedFiles.containsKey(key)) {
      return _downloadedFiles[key];
    }

    try {
      isDownloading.value = true;
      currentlyDownloadingKey.value = key;
      downloadProgress.value = 0.0;

      // Récupérer les informations du fichier depuis l'API
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final rosaryFileData = RosaryFileData.fromJson(json.decode(response.body));

        if (rosaryFileData.file?.link == null) {
          throw Exception('Lien de fichier manquant dans la réponse de l\'API');
        }

        // Créer le répertoire de cache s'il n'existe pas
        final directory = await getApplicationDocumentsDirectory();
        final rosaryDir = Directory('${directory.path}/rosary_audio');
        if (!await rosaryDir.exists()) {
          await rosaryDir.create(recursive: true);
        }

        // Nom du fichier local
        final fileName = '${rosaryFileData.bucketName}_$key.mp3';
        final filePath = '${rosaryDir.path}/$fileName';
        final file = File(filePath);

        // Télécharger le fichier
        final fileResponse = await http.get(
          Uri.parse(rosaryFileData.file!.link!),
          headers: {'accept': 'application/json'},
        );

        if (fileResponse.statusCode == 200) {
          await file.writeAsBytes(fileResponse.bodyBytes);
          _downloadedFiles[key] = filePath;
          _saveCachedFilePaths();
          return filePath;
        } else {
          throw Exception('Échec du téléchargement du fichier: ${fileResponse.statusCode}');
        }
      } else {
        throw Exception('Échec de récupération des informations du fichier: ${response.statusCode}');
      }
    } catch (e) {
      log('Erreur lors du téléchargement du fichier: $e');
      return null;
    } finally {
      isDownloading.value = false;
      currentlyDownloadingKey.value = '';
      downloadProgress.value = 0.0;
    }
  }

  /// Supprimer tous les fichiers téléchargés
  Future<void> clearAllDownloadedFiles() async {
    try {
      for (var filePath in _downloadedFiles.values) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _downloadedFiles.clear();
      _saveCachedFilePaths();
    } catch (e) {
      log('Erreur lors de la suppression des fichiers téléchargés: $e');
    }
  }
}
