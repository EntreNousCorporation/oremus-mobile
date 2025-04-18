import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/modules/rosary/data/model/rosary_file_data.dart';

/// Service qui gère le téléchargement et la mise en cache des fichiers audio pour le rosaire
/// Version optimisée pour iOS et Android avec support pour le streaming
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

  // Cache des URLs pour éviter des appels redondants à l'API
  final _cachedApiResponses = <String, RosaryFileData>{};

  @override
  void onInit() {
    super.onInit();
    _loadCachedFilePaths();
  }

  /// Charger les chemins de fichiers mis en cache depuis la BD
  Future<void> _loadCachedFilePaths() async {
    try {
      String? cachedData = DB.getData(KEY_DOWNLOADED_FILES);
      if (cachedData != null && cachedData.isNotEmpty) {
        Map<String, dynamic> data = json.decode(cachedData);

        for (var entry in data.entries) {
          final key = entry.key;
          final filePath = entry.value as String;

          // Vérification robuste de l'existence du fichier
          final file = File(filePath);
          final exists = await file.exists();
          final fileSize = exists ? await file.length() : 0;

          log('Vérification du fichier [${Platform.isIOS ? "iOS" : "Android"}]: $filePath, existe: $exists, taille: $fileSize octets');

          if (exists && fileSize > 0) {
            _downloadedFiles[key] = filePath;
          } else {
            log('Fichier en cache non trouvé ou invalide: $filePath');
          }
        }
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
      log('Sauvegarde de ${_downloadedFiles.length} chemins de fichiers');
    } catch (e) {
      log('Erreur lors de la sauvegarde des chemins de fichiers en cache: $e');
    }
  }

  /// Vérifier si le fichier est déjà téléchargé
  Future<bool> isFileDownloaded(int mystereIndex, int detailIndex) async {
    String key = getKey(mystereIndex, detailIndex);

    if (!_downloadedFiles.containsKey(key)) {
      return false;
    }

    // Double vérification que le fichier existe réellement sur le disque
    final filePath = _downloadedFiles[key]!;
    final file = File(filePath);
    final exists = await file.exists();
    final fileSize = exists ? await file.length() : 0;

    if (!exists || fileSize <= 0) {
      // Si le fichier n'existe plus, le retirer de la map
      log('Fichier marqué comme téléchargé mais introuvable: $filePath');
      _downloadedFiles.remove(key);
      _saveCachedFilePaths();
      return false;
    }

    return true;
  }

  /// Obtenir le chemin du fichier local s'il est téléchargé, null sinon
  Future<String?> getLocalFilePath(int mystereIndex, int detailIndex) async {
    String key = getKey(mystereIndex, detailIndex);

    if (!_downloadedFiles.containsKey(key)) {
      return null;
    }

    final filePath = _downloadedFiles[key] ?? '';
    final file = File(filePath);
    final exists = await file.exists();
    final fileSize = exists ? await file.length() : 0;

    if (!exists || fileSize <= 0) {
      // Si le fichier n'existe plus, le retirer de la map
      _downloadedFiles.remove(key);
      _saveCachedFilePaths();
      return null;
    }

    return filePath;
  }

  /// Obtenir la clé pour le mystère
  String getKey(int mystereIndex, int detailIndex) {
    return '$mystereIndex-$detailIndex';
  }

  /// Obtenir les informations du fichier de l'API (avec cache)
  Future<RosaryFileData?> getFileInfo() async {
    try {
      const cacheKey = 'rosary_api_response';

      // Vérifier si nous avons déjà ces informations en cache
      if (_cachedApiResponses.containsKey(cacheKey)) {
        return _cachedApiResponses[cacheKey];
      }

      // Sinon, faire l'appel API
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        log('Réponse API reçue');

        final rosaryFileData = RosaryFileData.fromJson(json.decode(responseBody));

        // Mettre en cache pour utilisation future
        _cachedApiResponses[cacheKey] = rosaryFileData;

        return rosaryFileData;
      } else {
        throw Exception('Échec de récupération des informations du fichier: ${response.statusCode}');
      }
    } catch (e) {
      log('Erreur lors de la récupération des informations de fichier: $e');
      return null;
    }
  }

  /// Télécharger le fichier audio pour un mystère spécifique
  /// Retourne le chemin du fichier une fois téléchargé
  Future<String?> downloadFile(int mystereIndex, int detailIndex) async {
    String key = getKey(mystereIndex, detailIndex);

    // Vérifier si le fichier est déjà téléchargé et valide
    if (_downloadedFiles.containsKey(key)) {
      final filePath = _downloadedFiles[key] ?? '';
      final file = File(filePath);
      final fileExists = await file.exists();
      final fileSize = fileExists ? await file.length() : 0;

      log('[${Platform.isIOS ? "iOS" : "Android"}] Vérification du fichier existant: $filePath, existe: $fileExists, taille: $fileSize octets');

      if (fileExists && fileSize > 0) {
        return filePath;
      } else {
        // Si le fichier n'existe plus ou est corrompu, le retirer de la map
        log('Fichier référencé mais non trouvé ou invalide: $filePath');
        _downloadedFiles.remove(key);
        _saveCachedFilePaths();
      }
    }

    try {
      isDownloading.value = true;
      currentlyDownloadingKey.value = key;
      downloadProgress.value = 0.0;

      log('[${Platform.isIOS ? "iOS" : "Android"}] Début du téléchargement pour mystère $mystereIndex, détail $detailIndex');

      // Récupérer les informations du fichier depuis l'API
      final rosaryFileData = await getFileInfo();

      if (rosaryFileData == null || rosaryFileData.file?.link == null) {
        throw Exception('Lien de fichier manquant dans la réponse de l\'API');
      }

      // Obtenir le répertoire approprié selon la plateforme
      Directory appDocDir;
      if (Platform.isIOS) {
        // Sur iOS, utiliser le répertoire de documents qui est plus fiable
        appDocDir = await getApplicationDocumentsDirectory();
      } else {
        // Sur Android, on peut aussi utiliser le répertoire de documents
        appDocDir = await getApplicationDocumentsDirectory();
      }

      log('Répertoire de base: ${appDocDir.path}');

      // Créer un sous-répertoire pour les fichiers audio
      final rosaryDirPath = '${appDocDir.path}/rosary_audio';
      final rosaryDir = Directory(rosaryDirPath);

      if (!await rosaryDir.exists()) {
        await rosaryDir.create(recursive: true);
      }

      // Nom du fichier local avec horodatage pour éviter les collisions
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'mystere_${key}_${timestamp}_${rosaryFileData.bucketName}.mp3';
      final filePath = '${rosaryDir.path}/$fileName';

      log('Téléchargement du fichier depuis: ${rosaryFileData.file!.link}');
      log('Chemin de destination: $filePath');

      // Télécharger le fichier avec un client HTTP configuré pour de meilleurs délais
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(rosaryFileData.file!.link!));
        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode == 200) {
          final file = File(filePath);

          // Écrire le fichier par flux pour une meilleure gestion de la mémoire
          final fileStream = file.openWrite();
          await streamedResponse.stream.pipe(fileStream);
          await fileStream.flush();
          await fileStream.close();

          // Vérifier que le fichier a bien été écrit
          final fileExists = await file.exists();
          final fileSize = fileExists ? await file.length() : 0;

          log('Fichier écrit, existe: $fileExists, taille: $fileSize octets');

          if (fileExists && fileSize > 0) {
            _downloadedFiles[key] = filePath;
            _saveCachedFilePaths();
            return filePath;
          } else {
            throw Exception('Le fichier téléchargé est vide ou n\'a pas été écrit correctement');
          }
        } else {
          throw Exception('Échec du téléchargement du fichier: ${streamedResponse.statusCode}');
        }
      } finally {
        client.close();
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
          log('Fichier supprimé: $filePath');
        }
      }
      _downloadedFiles.clear();
      _saveCachedFilePaths();
      log('Tous les fichiers téléchargés ont été supprimés');
    } catch (e) {
      log('Erreur lors de la suppression des fichiers téléchargés: $e');
    }
  }

  /// Obtenir directement l'URL de streaming pour un mystère
  Future<String?> getStreamingUrl() async {
    try {
      final rosaryFileData = await getFileInfo();
      return rosaryFileData?.file?.link;
    } catch (e) {
      log('Erreur lors de la récupération de l\'URL de streaming: $e');
      return null;
    }
  }
}
