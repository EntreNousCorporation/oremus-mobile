import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:oremusapp/app/modules/rosary/services/audio_file_manager_service.dart';

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

class AudioPlayerService extends GetxService {
  static AudioPlayerService get to => Get.find<AudioPlayerService>();

  // Player
  late AudioPlayer _audioPlayer;
  AudioPlayer get audioPlayer => _audioPlayer;

  // Audio file manager service
  late AudioFileManagerService _fileManagerService;

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

  // Flag pour indiquer si l'audio est terminé
  final isCompleted = false.obs;

  // Créer un stream combiné pour obtenir des mises à jour de position
  Stream<PositionData> get positionDataStream =>
      CombineLatestStream.combine3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream, (position, bufferedPosition, duration) => PositionData(
        position: position,
        bufferedPosition: bufferedPosition,
        duration: duration ?? Duration.zero,
      ),
      );

  // Liste des mystères et leurs détails
  final List<String> mysteres = [
    'Mystères Joyeux',
    'Mystères Lumineux',
    'Mystères Douloureux',
    'Mystères Glorieux',
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
    0: { // Mystères Joyeux
      0: '', //Assets.audiosAnnonciation,
      // Ajouter d'autres fallbacks si disponibles
    },
    // Ajouter d'autres mystères si des fallbacks sont disponibles
  };

  late String _artworkFilePath;

  @override
  Future<void> onInit() async {
    super.onInit();
    _fileManagerService = Get.find<AudioFileManagerService>();
    _artworkFilePath = await prepareArtworkFile();
    _initAudioPlayer();
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
      this.isPlaying.value = isPlaying && processingState == ProcessingState.ready;

      // Afficher le mini lecteur si l'audio est en cours de lecture ou en pause
      if (isPlaying || processingState == ProcessingState.ready) {
        showMiniPlayer.value = true;
      }

      // Si la lecture est terminée, marquer comme terminé
      if (processingState == ProcessingState.completed) {
        isCompleted.value = true;
        this.isPlaying.value = false; // Assure que le bouton play est affiché
      }
    });

    // Écouter les erreurs du lecteur
    _audioPlayer.playbackEventStream.listen((event) {},
      onError: (Object e, StackTrace stackTrace) {
        log('Erreur de lecture audio: $e');
        errorMessage.value = 'Erreur de lecture. Veuillez réessayer.';
      },
    );
  }

  // Méthode pour charger un audio avec gestion du téléchargement
  Future<void> loadAudio(int mystereIndex, int detailIndex) async {
    try {
      isLoadingAudio.value = true;
      errorMessage.value = '';

      currentMystereIndex.value = mystereIndex;
      currentMystereDetailIndex.value = detailIndex;
      currentMystereTitle.value = mysteres[mystereIndex];
      currentMystereDetailTitle.value = mystereDetails[mystereIndex][detailIndex];

      // Arrêter l'audio en cours s'il y en a un
      await _audioPlayer.stop();

      // Vérifier si le fichier est déjà téléchargé
      String? localFilePath = _fileManagerService.getLocalFilePath(mystereIndex, detailIndex);

      // Si le fichier n'est pas téléchargé, le télécharger
      if (localFilePath == null) {
        isDownloading.value = true;
        localFilePath = await _fileManagerService.downloadFile(mystereIndex, detailIndex);
        isDownloading.value = false;
      }

      // Préparer la source audio
      late AudioSource audioSource;

      if (localFilePath != null) {
        // Utiliser le fichier téléchargé
        audioSource = AudioSource.uri(
          Uri.file(localFilePath),
          tag: MediaItem(
            id: '$mystereIndex-$detailIndex',
            album: 'Rosaire',
            title: mystereDetails[mystereIndex][detailIndex],
            artist: mysteres[mystereIndex],
            artUri: Uri.file(_artworkFilePath),
          ),
        );
      } else {
        // Utiliser le fichier de secours si disponible
        final fallbackPath = fallbackAudioFiles[mystereIndex]?[detailIndex];

        if (fallbackPath != null) {
          log('Utilisation du fichier de secours pour $mystereIndex-$detailIndex');
          audioSource = AudioSource.asset(
            fallbackPath,
            tag: MediaItem(
              id: '$mystereIndex-$detailIndex',
              album: 'Rosaire',
              title: mystereDetails[mystereIndex][detailIndex],
              artist: mysteres[mystereIndex],
            ),
          );
        } else {
          throw Exception('Aucun fichier audio disponible pour ce mystère');
        }
      }

      // Charger la source audio
      await _audioPlayer.setAudioSource(audioSource);

      // Réinitialiser le flag de complétion
      isCompleted.value = false;

      // Montrer le mini lecteur
      showMiniPlayer.value = true;

      // Démarrer la lecture automatiquement
      _audioPlayer.play();
    } catch (e) {
      log('Erreur lors du chargement de l\'audio: $e');
      errorMessage.value = 'Impossible de charger l\'audio. Veuillez réessayer.';
    } finally {
      isLoadingAudio.value = false;
    }
  }

  // Méthode pour télécharger tous les fichiers audio d'un mystère
  Future<void> preloadMysteryFiles(int mystereIndex) async {
    try {
      final detailsCount = mystereDetails[mystereIndex].length;

      for (int i = 0; i < detailsCount; i++) {
        if (!_fileManagerService.isFileDownloaded(mystereIndex, i)) {
          await _fileManagerService.downloadFile(mystereIndex, i);
        }
      }
    } catch (e) {
      log('Erreur lors du préchargement des fichiers: $e');
    }
  }

  // Méthode pour gérer la lecture/pause avec gestion correcte de la fin d'audio
  void playPause() async {
    // Si l'audio est terminé, le repositionner au début et lancer la lecture immédiatement
    if (isCompleted.value) {
      try {
        isCompleted.value = false;  // Désactiver le statut "complété"
        isPlaying.value = true;     // Prérégler l'état de lecture pour un feedback UI immédiat

        // Repositionner au début et lancer la lecture
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      } catch (e) {
        log('Erreur lors du redémarrage de l\'audio: $e');
        isPlaying.value = false;    // En cas d'erreur, réinitialiser l'état de lecture
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

  void navigateToPreviousMystery() async {
    if (currentMystereDetailIndex.value > 0) {
      await loadAudio(currentMystereIndex.value, currentMystereDetailIndex.value - 1);
    } else {
      if (currentMystereIndex.value > 0) {
        final previousIndex = currentMystereIndex.value - 1;
        final lastDetailIndex = mystereDetails[previousIndex].length - 1;
        await loadAudio(previousIndex, lastDetailIndex);
      }
    }
  }

  void navigateToNextMystery() async {
    if (currentMystereDetailIndex.value < mystereDetails[currentMystereIndex.value].length - 1) {
      await loadAudio(currentMystereIndex.value, currentMystereDetailIndex.value + 1);
    } else {
      if (currentMystereIndex.value < mysteres.length - 1) {
        await loadAudio(currentMystereIndex.value + 1, 0);
      }
    }
  }

  // Fermer le lecteur et arrêter toute notification
  void closeMiniPlayer() {
    _audioPlayer.stop();
    showMiniPlayer.value = false;
    isCompleted.value = false;
    errorMessage.value = '';
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
  }

  // Détruire le service proprement
  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
