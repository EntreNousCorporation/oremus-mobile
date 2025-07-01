import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_waveform/just_waveform.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/rosary/data/model/rosary_file_data.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_file_manager_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

// Classe pour les données de position (comme dans votre code original)
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });
}

// Paramètres pour le traitement de waveform en arrière-plan
class WaveformProcessParams {
  final String filePath;
  final int sampleCount;

  WaveformProcessParams({required this.filePath, this.sampleCount = 50});
}

class AudioPlayerService extends GetxService {
  static AudioPlayerService get to => Get.find<AudioPlayerService>();

  // Player
  late AudioPlayer _audioPlayer;
  AudioPlayer get audioPlayer => _audioPlayer;

  // Audio file manager service
  late AudioFileManagerService _fileManagerService;

  final waveformData = Rx<Uint8List?>(null);
  final isWaveformLoading = true.obs;
  final waveformProgressStream = rxdart.BehaviorSubject<WaveformProgress>();

  // État observable
  final isPlaying = false.obs;
  final currentMystereIndex = 0.obs;
  final currentMystereDetailIndex = 0.obs;
  final currentMystereTitle = ''.obs;
  final currentMystereDetailTitle = ''.obs;
  final showMiniPlayer = false.obs;

  // Nouveaux états pour la gestion des téléchargements
  final isDownloading = false.obs;
  final downloadProgress = 0.0.obs;
  final isLoadingAudio = false.obs;
  final errorMessage = ''.obs;
  final isStreamingMode = false.obs;

  // Flag pour indiquer si l'audio est terminé
  final isCompleted = false.obs;

  // Constante pour le nombre de secondes à avancer/reculer
  static const int seekDurationInSeconds = 10;
  static const int continuousSeekInterval = 300; // en millisecondes

  // Pour la fonction de recherche continue
  Timer? _continuousSeekTimer;
  bool _isContinuousSeekActive = false;

  // Nouveau: pour la génération de waveform en arrière-plan
  bool _isWaveformGenerationInProgress = false;
  Completer<void>? _waveformGenerationCompleter;

  // Créer un stream combiné pour obtenir des mises à jour de position
  Stream<PositionData> get positionDataStream => rxdart.CombineLatestStream
      .combine3<Duration, Duration, Duration?, PositionData>(
    _audioPlayer.positionStream,
    _audioPlayer.bufferedPositionStream,
    _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
      position: position,
      bufferedPosition: bufferedPosition,
      duration: duration ?? Duration.zero,
    ),
  );

  // Liste des mystères et leurs détails
  final List<String> mysteres = [
    'Joyeux',
    'Lumineux',
    'Douloureux',
    'Glorieux',
  ];

  final List<List<String>> mystereDetails = [
    [
      'L\'Annonciation',
      'La Visitation',
      'La Nativité',
      'La Présentation au Temple',
      'Le Recouvrement au Temple',
    ],
    [
      'Le Baptême au Jourdain',
      'Les Noces de Cana',
      'L\'Annonce du Royaume',
      'La Transfiguration',
      'L\'Institution de l\'Eucharistie',
    ],
    [
      'L\'Agonie à Gethsémani',
      'La Flagellation',
      'Le Couronnement d\'épines',
      'Le Portement de la Croix',
      'La Crucifixion',
    ],
    [
      'La Résurrection',
      'L\'Ascension',
      'La Pentecôte',
      'L\'Assomption',
      'Le Couronnement de Marie',
    ],
  ];

  // Mappez chaque mystère à son fichier audio de secours
  final Map<int, Map<int, String>> fallbackAudioFiles = {
    0: {
      // Mystères Joyeux
      0: '', //Assets.audiosAnnonciation,
      // Ajouter d'autres fallbacks si disponibles
    },
    // Ajouter d'autres mystères si des fallbacks sont disponibles
  };

  late String _artworkFilePath;

  // Stocker le téléchargement en cours
  String? _currentDownloadUrl;
  String? _currentDownloadKey;
  bool _isBackgroundDownloadInProgress = false;

  final playbackSpeed = 1.0.obs;
  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Clé pour la sauvegarde de la vitesse dans la BD
  static const String KEY_PLAYBACK_SPEED = 'playback_speed';

  @override
  Future<void> onInit() async {
    super.onInit();
    _fileManagerService = Get.isRegistered<AudioFileManagerService>()
        ? Get.find<AudioFileManagerService>()
        : Get.put<AudioFileManagerService>(AudioFileManagerService(),
        permanent: true);
    _artworkFilePath = await prepareArtworkFile();
    _initAudioPlayer();

    // Nouveau: créer le dossier de cache pour les waveforms
    _createWaveformCacheDir();

    // Charger la vitesse sauvegardée
    _loadSavedSpeed();

    // Écouter les changements de vitesse
    ever(playbackSpeed, (double speed) => _onSpeedChanged(speed));
  }

  void _loadSavedSpeed() {
    try {
      String? savedSpeed = DB.getData(KEY_PLAYBACK_SPEED);
      if (savedSpeed != null && savedSpeed.isNotEmpty) {
        double speed = double.tryParse(savedSpeed) ?? 1.0;
        if (speedOptions.contains(speed)) {
          playbackSpeed.value = speed;
        }
      }
    } catch (e) {
      log('Erreur lors du chargement de la vitesse: $e');
    }
  }

  // Sauvegarder la vitesse
  void _saveSpeed(double speed) {
    try {
      DB.saveData(KEY_PLAYBACK_SPEED, speed.toString());
    } catch (e) {
      log('Erreur lors de la sauvegarde de la vitesse: $e');
    }
  }

  // Gérer les changements de vitesse
  Future<void> _onSpeedChanged(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
      _saveSpeed(speed);
      log('Vitesse de lecture changée: ${speed}x');
    } catch (e) {
      log('Erreur lors du changement de vitesse: $e');
    }
  }

  // Méthode publique pour changer la vitesse
  void setPlaybackSpeed(double speed) {
    if (speedOptions.contains(speed)) {
      playbackSpeed.value = speed;
    }
  }

  // NOUVEAU: Passer à la vitesse suivante (cycle)
  void cycleSpeed() {
    int currentIndex = speedOptions.indexOf(playbackSpeed.value);
    int nextIndex = (currentIndex + 1) % speedOptions.length;
    setPlaybackSpeed(speedOptions[nextIndex]);
  }

  // NOUVEAU: Réinitialiser à la vitesse normale
  void resetToNormalSpeed() {
    setPlaybackSpeed(1.0);
  }

  // Nouveau: Créer un répertoire pour stocker les fichiers waveform en cache
  Future<String> _createWaveformCacheDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final cacheDirPath = '${appDocDir.path}/waveform_cache';

    final cacheDir = Directory(cacheDirPath);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return cacheDirPath;
  }

  Future<void> _initAudioPlayer() async {
    // Créer le lecteur audio
    _audioPlayer = AudioPlayer();

    // Configurer la session audio pour la lecture en arrière-plan
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Écouter les changements d'état du lecteur
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      // Mettre à jour l'état
      this.isPlaying.value =
          isPlaying && processingState == ProcessingState.ready;

      // Afficher le mini lecteur si l'audio est en cours de lecture ou en pause
      if (isPlaying || processingState == ProcessingState.ready) {
        showMiniPlayer.value = true;
      }

      // Si la lecture est terminée, marquer comme terminé
      if (processingState == ProcessingState.completed) {
        isCompleted.value = true;
        this.isPlaying.value = false; // Assure que le bouton play est affiché

        // Si nous étions en mode streaming, télécharger le fichier complètement pour la prochaine fois
        if (isStreamingMode.value &&
            _currentDownloadUrl != null &&
            _currentDownloadKey != null) {
          _completeBackgroundDownload();
        }
      }
    });

    // Écouter les erreurs du lecteur
    _audioPlayer.playbackEventStream.listen(
          (event) {},
      onError: (Object e, StackTrace stackTrace) {
        log('Erreur de lecture audio: $e');
        errorMessage.value = 'Erreur de lecture. Veuillez réessayer svp';
      },
    );
  }

  // Méthode pour charger un audio avec gestion du téléchargement et streaming
  Future<void> loadAudio(int mystereIndex, int detailIndex) async {
    try {
      isLoadingAudio.value = true;
      errorMessage.value = '';
      isStreamingMode.value = false;

      currentMystereIndex.value = mystereIndex;
      currentMystereDetailIndex.value = detailIndex;
      currentMystereTitle.value = mysteres[mystereIndex];
      currentMystereDetailTitle.value =
      mystereDetails[mystereIndex][detailIndex];

      // Arrêter l'audio en cours s'il y en a un
      await _audioPlayer.stop();

      // Réinitialiser les variables de téléchargement
      _currentDownloadUrl = null;
      _currentDownloadKey = null;

      // Vérifier si le fichier est déjà téléchargé
      String? localFilePath =
      await _fileManagerService.getLocalFilePath(mystereIndex, detailIndex);

      if (localFilePath != null) {
        log('Utilisation du fichier local: $localFilePath');
        // Utiliser le fichier local existant
        await _playLocalFile(mystereIndex, detailIndex, localFilePath);
      } else {
        // Obtenir les informations du fichier depuis l'API pour le streaming
        final response = await http.get(
          Uri.parse(_fileManagerService.baseUrl),
          headers: {'accept': 'application/json'},
        );

        if (response.statusCode == 200) {
          final rosaryFileData =
          RosaryFileData.fromJson(json.decode(response.body));

          if (rosaryFileData.file?.link != null) {
            final audioUrl = rosaryFileData.file?.link ?? '';
            final mysteryKey =
            _fileManagerService.getKey(mystereIndex, detailIndex);

            // S'assurer que l'URL est correctement encodée
            final encodedUrl = Uri.encodeFull(audioUrl);
            log('URL encodée: $encodedUrl');

            // Stocker l'URL pour téléchargement en arrière-plan
            _currentDownloadUrl = encodedUrl;
            _currentDownloadKey = mysteryKey;

            // Sur iOS, télécharger d'abord le fichier puis le lire localement
            if (Platform.isIOS) {
              isDownloading.value = true;
              String? filePath;
              try {
                filePath = await _fileManagerService.downloadFile(
                    mystereIndex, detailIndex);
              } catch (e) {
                log('Erreur pendant le téléchargement sur iOS: $e');
                errorMessage.value =
                'Erreur de téléchargement. Veuillez réessayer.';
                isDownloading.value = false;
                return;
              }

              isDownloading.value = false;
              if (filePath != null) {
                try {
                  await _playLocalFile(mystereIndex, detailIndex, filePath);
                } catch (e) {
                  log('Erreur lors de la lecture du fichier local sur iOS: $e');
                  errorMessage.value = 'Erreur de lecture. Veuillez réessayer.';
                }
              } else {
                errorMessage.value =
                'Échec du téléchargement. Veuillez réessayer.';
              }
            }
            // Sur Android, utiliser le streaming
            else {
              // Configurer la source en mode streaming
              try {
                final audioSource = AudioSource.uri(
                  Uri.parse(encodedUrl),
                  tag: MediaItem(
                    id: '$mystereIndex-$detailIndex',
                    album: 'Rosaire',
                    //title: mystereDetails[mystereIndex][detailIndex],
                    title: 'Méditation des mystères',
                    artist: mysteres[mystereIndex],
                    artUri: Uri.file(_artworkFilePath),
                  ),
                );

                // Charger et démarrer la lecture en streaming
                await _audioPlayer.setAudioSource(audioSource);

                // Appliquer la vitesse pour le streaming
                await _audioPlayer.setSpeed(playbackSpeed.value);

                isStreamingMode.value = true;
                showMiniPlayer.value = true;
                isCompleted.value = false;

                // Démarrer le téléchargement en arrière-plan pendant la lecture
                _startBackgroundDownload(
                    encodedUrl, mysteryKey, mystereIndex, detailIndex);

                // Commencer la lecture
                _audioPlayer.play();
              } catch (e) {
                log('Erreur lors de la configuration du streaming: $e');
                errorMessage.value = 'Erreur de streaming. Veuillez réessayer.';
              }
            }
          } else {
            throw Exception(
                'Lien de fichier manquant dans la réponse de l\'API');
          }
        } else {
          throw Exception(
              'Échec de récupération des informations du fichier: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Erreur lors du chargement de l\'audio: $e');
      errorMessage.value =
      'Impossible de charger l\'audio. Veuillez réessayer.';
    } finally {
      isLoadingAudio.value = false;
    }
  }

  // Jouer un fichier local avec génération optimisée du waveform
  Future<void> _playLocalFile(int mystereIndex, int detailIndex, String filePath) async {
    try {
      // Vérification supplémentaire du fichier avant la lecture
      final file = File(filePath);
      final exists = await file.exists();
      final fileSize = exists ? await file.length() : 0;

      if (!exists || fileSize <= 0) {
        throw Exception('Fichier introuvable ou vide: $filePath');
      }

      // Sur iOS, faire une vérification supplémentaire que le fichier peut être lu
      if (Platform.isIOS) {
        try {
          final testBytes = await file.readAsBytes().timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException(
                'Lecture du fichier dépassé le délai imparti'),
          );

          if (testBytes.isEmpty) {
            throw Exception(
                'Le fichier existe mais ne peut pas être lu correctement sur iOS');
          }
          log('Vérification de lecture réussie avant la configuration de l\'audio source');
        } catch (e) {
          log('Erreur lors de la vérification de lecture sur iOS: $e');
          throw Exception('Vérification de lecture échouée: $e');
        }
      }

      // Utiliser un URI encodé pour la lecture
      final audioUri = Uri.file(filePath);
      log('URI du fichier pour lecture: ${audioUri.toString()}');

      final audioSource = AudioSource.uri(
        audioUri,
        tag: MediaItem(
          id: '$mystereIndex-$detailIndex',
          album: 'Rosaire',
          //title: mystereDetails[mystereIndex][detailIndex],
          title: 'Méditation des mystères',
          artist: mysteres[mystereIndex],
          artUri: Uri.file(_artworkFilePath),
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
      // Appliquer la vitesse courante après le chargement
      await _audioPlayer.setSpeed(playbackSpeed.value);

      // Déclencher le chargement du waveform en arrière-plan après avoir configuré la source audio
      // mais sans attendre que ce soit terminé pour démarrer la lecture
      _loadWaveformInBackground(filePath);

      isStreamingMode.value = false;
      showMiniPlayer.value = true;
      isCompleted.value = false;
      _audioPlayer.play();
    } catch (e) {
      log('Erreur lors de la lecture du fichier local: $e');
      rethrow;
    }
  }

  // Charger le waveform en arrière-plan pour ne pas bloquer l'interface
  void _loadWaveformInBackground(String filePath) {
    // On utilise un timer court pour éviter de bloquer le thread UI
    Timer(const Duration(milliseconds: 50), () {
      loadWaveform(filePath);
    });
  }

  // Démarrer le téléchargement en arrière-plan pendant la lecture
  void _startBackgroundDownload(String audioUrl, String mysteryKey, int mystereIndex, int detailIndex) async {
    if (_isBackgroundDownloadInProgress) return;

    _isBackgroundDownloadInProgress = true;

    try {
      isDownloading.value = true;

      // Télécharger le fichier en arrière-plan
      await _fileManagerService.downloadFile(mystereIndex, detailIndex);

      log('Téléchargement en arrière-plan terminé pour: $mysteryKey');
    } catch (e) {
      log('Erreur lors du téléchargement en arrière-plan: $e');
    } finally {
      isDownloading.value = false;
      _isBackgroundDownloadInProgress = false;
    }
  }

  // Compléter le téléchargement en arrière-plan à la fin de la lecture
  void _completeBackgroundDownload() async {
    if (_isBackgroundDownloadInProgress ||
        _currentDownloadUrl == null ||
        _currentDownloadKey == null) {
      return;
    }

    final parts = _currentDownloadKey!.split('-');
    if (parts.length == 2) {
      final mystereIndex = int.tryParse(parts[0]);
      final detailIndex = int.tryParse(parts[1]);

      if (mystereIndex != null && detailIndex != null) {
        // Vérifier si le fichier a déjà été téléchargé entre temps
        final localPath = await _fileManagerService.getLocalFilePath(
            mystereIndex, detailIndex);
        if (localPath == null) {
          log('Début du téléchargement complet après la lecture');
          try {
            await _fileManagerService.downloadFile(mystereIndex, detailIndex);
            log('Téléchargement complet après la lecture réussi');
          } catch (e) {
            log('Erreur lors du téléchargement complet après la lecture: $e');
          }
        }
      }
    }
  }

  // Méthode pour télécharger tous les fichiers audio d'un mystère
  Future<void> preloadMysteryFiles(int mystereIndex) async {
    try {
      final detailsCount = mystereDetails[mystereIndex].length;

      for (int i = 0; i < detailsCount; i++) {
        if (!await _fileManagerService.isFileDownloaded(mystereIndex, i)) {
          await _fileManagerService.downloadFile(mystereIndex, i);
        }
      }
    } catch (e) {
      log('Erreur lors du préchargement des fichiers: $e');
    }
  }

  // Générer un hash MD5 pour le cache du waveform
  Future<String> _getFileHash(String filePath) async {
    final file = File(filePath);
    // Pour les gros fichiers, utiliser juste le chemin, la taille et la date de modification est plus rapide
    final size = await file.length();
    final modified = await file.lastModified();
    final hashInput = '$filePath-$size-${modified.millisecondsSinceEpoch}';
    return md5.convert(utf8.encode(hashInput)).toString();
  }

  // Version optimisée de loadWaveform avec mise en cache
  Future<void> loadWaveform(String filePath) async {
    // Si un waveform est déjà en cours de génération, attendre qu'il soit terminé
    if (_isWaveformGenerationInProgress) {
      await _waveformGenerationCompleter?.future;
      return;
    }

    try {
      _isWaveformGenerationInProgress = true;
      _waveformGenerationCompleter = Completer<void>();

      isWaveformLoading.value = true;
      waveformData.value = null;

      // Vérifier que le fichier existe
      final file = File(filePath);
      if (!await file.exists()) {
        log('Fichier audio introuvable pour la forme d\'onde: $filePath');
        isWaveformLoading.value = false;
        _isWaveformGenerationInProgress = false;
        _waveformGenerationCompleter?.complete();
        return;
      }

      // Générer un hash pour le fichier audio pour l'utiliser comme clé de cache
      final fileHash = await _getFileHash(filePath);
      final cacheDirPath = await _createWaveformCacheDir();
      final waveformCachePath = '$cacheDirPath/waveform-$fileHash.wave';
      final waveformCacheFile = File(waveformCachePath);

      // Vérifier si le waveform est déjà en cache
      if (await waveformCacheFile.exists()) {
        log('Chargement du waveform depuis le cache: $waveformCachePath');
        try {

          // Traiter le waveform en arrière-plan
          final params = WaveformProcessParams(
              filePath: waveformCachePath,
              sampleCount: 50
          );

          final processedData = await compute(_processWaveform, params);
          waveformData.value = processedData;
          isWaveformLoading.value = false;
          log('Waveform chargé depuis le cache avec succès');

          _isWaveformGenerationInProgress = false;
          _waveformGenerationCompleter?.complete();
          return;
        } catch (e) {
          log('Erreur lors du chargement du waveform depuis le cache: $e');
          // Si le cache est corrompu, supprimer le fichier cache et continuer avec la génération
          try {
            await waveformCacheFile.delete();
          } catch (_) {}
        }
      }

      JustWaveform.extract(
        audioInFile: file,
        waveOutFile: waveformCacheFile,
        // Pas besoin de paramètres options ici car JustWaveform utilise ses propres valeurs par défaut
      ).listen(
            (progress) {
          // Mettre à jour le flux de progression
          waveformProgressStream.add(progress);

          // Si le traitement est terminé et que nous avons une forme d'onde
          if (progress.progress == 1.0 && progress.waveform != null) {
            // Traiter le waveform en arrière-plan
            compute(_processWaveform, WaveformProcessParams(
                filePath: waveformCachePath,
                sampleCount: 50
            )).then((processedData) {
              waveformData.value = processedData;
              isWaveformLoading.value = false;
              log('Waveform généré et traité avec succès');

              _isWaveformGenerationInProgress = false;
              _waveformGenerationCompleter?.complete();
            }).catchError((e) {
              log('Erreur lors du traitement du waveform: $e');
              isWaveformLoading.value = false;

              _isWaveformGenerationInProgress = false;
              _waveformGenerationCompleter?.complete();
            });
          }
        },
        onError: (e) {
          log('Erreur lors de la génération de la forme d\'onde: $e');
          isWaveformLoading.value = false;
          _isWaveformGenerationInProgress = false;
          _waveformGenerationCompleter?.complete();
        },
        onDone: () {
          // Ne pas mettre isWaveformLoading à false ici car c'est fait après le traitement
          if (!waveformProgressStream.hasValue ||
              waveformProgressStream.value.progress < 1.0 ||
              waveformProgressStream.value.waveform == null) {
            isWaveformLoading.value = false;
            _isWaveformGenerationInProgress = false;
            _waveformGenerationCompleter?.complete();
          }
        },
      );
    } catch (e) {
      log('Erreur lors de la génération de la forme d\'onde: $e');
      isWaveformLoading.value = false;
      _isWaveformGenerationInProgress = false;
      _waveformGenerationCompleter?.complete();
    }
  }

  // Traitement du waveform à exécuter dans un isolate
  static Future<Uint8List> _processWaveform(WaveformProcessParams params) async {
    try {
      final waveFile = File(params.filePath);
      final waveform = await JustWaveform.parse(waveFile);

      final sampleCount = params.sampleCount;
      final bytes = Uint8List(sampleCount);
      final duration = waveform.duration;

      for (var i = 0; i < sampleCount; i++) {
        // Calculer la position en millisecondes dans le fichier audio
        final position = Duration(milliseconds: (i * duration.inMilliseconds ~/ sampleCount));

        // Calculer l'index de pixel correspondant dans la forme d'onde
        final pixelIndex = waveform.positionToPixel(position).toInt();

        // Obtenir les valeurs min et max pour ce pixel
        final minVal = waveform.getPixelMin(pixelIndex);
        final maxVal = waveform.getPixelMax(pixelIndex);

        // Utiliser la valeur absolue la plus grande
        final amplitude = math.max(minVal.abs(), maxVal.abs());

        // Normaliser entre 0 et 255 selon le type de format audio
        if (waveform.flags == 0) {
          // Normalisation 16 bits
          bytes[i] = ((amplitude / 32768) * 255).clamp(0, 255).toInt();
        } else {
          // Normalisation 8 bits
          bytes[i] = ((amplitude / 128) * 255).clamp(0, 255).toInt();
        }
      }

      return bytes;
    } catch (e) {
      // En cas d'erreur, retourner un tableau vide
      log('Erreur dans l\'isolate _processWaveform: $e');
      return Uint8List(params.sampleCount);
    }
  }

  // Méthode pour gérer la lecture/pause avec gestion correcte de la fin d'audio
  void playPause() async {
    // Si l'audio est terminé, le repositionner au début et lancer la lecture immédiatement
    if (isCompleted.value) {
      try {
        isCompleted.value = false; // Désactiver le statut "complété"
        isPlaying.value =
        true; // Prérégler l'état de lecture pour un feedback UI immédiat

        // Repositionner au début et lancer la lecture
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      } catch (e) {
        log('Erreur lors du redémarrage de l\'audio: $e');
        isPlaying.value =
        false; // En cas d'erreur, réinitialiser l'état de lecture
        errorMessage.value = 'Erreur lors de la lecture. Veuillez réessayer.';
      }
    }
    // Sinon, comportement normal play/pause
    else {
      try {
        if (_audioPlayer.playing) {
          _audioPlayer.pause();
        } else {
          _audioPlayer.play();
        }
      } catch (e) {
        log('Erreur lors de la lecture/pause: $e');
        errorMessage.value = 'Erreur lors de la lecture. Veuillez réessayer.';
      }
    }
  }

  /// Avancer la lecture de N secondes
  Future<void> seekForward() async {
    try {
      final position = _audioPlayer.position;
      final duration = _audioPlayer.duration ?? Duration.zero;

      // Calculer la nouvelle position
      final newPosition =
          position + const Duration(seconds: seekDurationInSeconds);

      // Vérifier que la nouvelle position ne dépasse pas la durée totale
      if (newPosition < duration) {
        await _audioPlayer.seek(newPosition);
      } else {
        // Si on dépasse, aller à la fin
        await _audioPlayer.seek(duration);
      }
    } catch (e) {
      log('Erreur lors de l\'avance rapide: $e');
    }
  }

  /// Reculer la lecture de N secondes
  Future<void> seekBackward() async {
    try {
      final position = _audioPlayer.position;

      // Calculer la nouvelle position
      final newPosition =
          position - const Duration(seconds: seekDurationInSeconds);

      // Vérifier que la nouvelle position n'est pas négative
      if (newPosition > Duration.zero) {
        await _audioPlayer.seek(newPosition);
      } else {
        // Si on recule trop, aller au début
        await _audioPlayer.seek(Duration.zero);
      }
    } catch (e) {
      log('Erreur lors du recul: $e');
    }
  }

  /// Démarrer l'avance continue
  void startContinuousSeekForward() {
    if (_isContinuousSeekActive) return;

    _isContinuousSeekActive = true;
    // Exécuter une première fois immédiatement
    seekForward();

    // Puis démarrer un timer pour répéter
    _continuousSeekTimer = Timer.periodic(
        const Duration(milliseconds: continuousSeekInterval), (timer) {
      seekForward();
    });
  }

  /// Démarrer le recul continu
  void startContinuousSeekBackward() {
    if (_isContinuousSeekActive) return;

    _isContinuousSeekActive = true;
    // Exécuter une première fois immédiatement
    seekBackward();

    // Puis démarrer un timer pour répéter
    _continuousSeekTimer = Timer.periodic(
        const Duration(milliseconds: continuousSeekInterval), (timer) {
      seekBackward();
    });
  }

  /// Arrêter le mode de recherche continue
  void stopContinuousSeek() {
    _isContinuousSeekActive = false;
    _continuousSeekTimer?.cancel();
    _continuousSeekTimer = null;
  }

  void navigateToPreviousMystery() async {
    if (currentMystereDetailIndex.value > 0) {
      await loadAudio(
          currentMystereIndex.value, currentMystereDetailIndex.value - 1);
    } else {
      if (currentMystereIndex.value > 0) {
        final previousIndex = currentMystereIndex.value - 1;
        final lastDetailIndex = mystereDetails[previousIndex].length - 1;
        await loadAudio(previousIndex, lastDetailIndex);
      }
    }
  }

  void navigateToNextMystery() async {
    if (currentMystereDetailIndex.value <
        mystereDetails[currentMystereIndex.value].length - 1) {
      await loadAudio(
          currentMystereIndex.value, currentMystereDetailIndex.value + 1);
    } else {
      if (currentMystereIndex.value < mysteres.length - 1) {
        await loadAudio(currentMystereIndex.value + 1, 0);
      }
    }
  }

  // Fermer le lecteur et arrêter toute notification
  Future<void> closeMiniPlayer() async {
    // On arrête la lecture
    if (isPlaying.value) {
      await _audioPlayer.pause();
    }

    // On attend un court instant pour permettre à l'animation de se terminer
    // Cette méthode est maintenant appelée après l'animation dans MiniPlayer
    isPlaying.value = false;
    showMiniPlayer.value = false;

    _audioPlayer.stop();
    showMiniPlayer.value = false;
    isCompleted.value = false;
    errorMessage.value = '';
    isStreamingMode.value = false;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Supprimer tous les fichiers téléchargés
  Future<void> clearAllDownloadedFiles() async {
    await _fileManagerService.clearAllDownloadedFiles();

    // Supprimer également les fichiers de waveform en cache
    try {
      final cacheDirPath = await _createWaveformCacheDir();
      final cacheDir = Directory(cacheDirPath);
      if (await cacheDir.exists()) {
        final files = await cacheDir.list().toList();
        for (var entity in files) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      log('Cache des waveforms nettoyé avec succès');
    } catch (e) {
      log('Erreur lors du nettoyage du cache des waveforms: $e');
    }
  }

  int getMysteryIndexForCurrentDay() {
    // Obtenir le jour de la semaine (1 = lundi, 7 = dimanche)
    final weekday = DateTime.now().weekday;

    switch (weekday) {
      case 1: // Lundi
      case 6: // Samedi
        return 0; // Mystères Joyeux

      case 2: // Mardi
      case 5: // Vendredi
        return 2; // Mystères Douloureux

      case 3: // Mercredi
      case 7: // Dimanche
        return 3; // Mystères Glorieux

      case 4: // Jeudi
        return 1; // Mystères Lumineux

      default:
        return 0; // Par défaut, mystères Joyeux (ne devrait jamais arriver)
    }
  }

  String getCurrentDayName() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }

  @override
  void onClose() {
    stopContinuousSeek();
    _audioPlayer.dispose();
    super.onClose();
  }
}
