import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:rxdart/rxdart.dart';

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

  // État observable
  final isPlaying = false.obs;
  final currentMystereIndex = 0.obs;
  final currentMystereDetailIndex = 0.obs;
  final currentMystereTitle = ''.obs;
  final currentMystereDetailTitle = ''.obs;
  final showMiniPlayer = false.obs;

  // Flag pour indiquer si l'audio est terminé
  final isCompleted = false.obs;

  // Créer un stream combiné pour obtenir des mises à jour de position
  Stream<PositionData> get positionDataStream =>
      CombineLatestStream.combine3<Duration, Duration, Duration?, PositionData>(
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
    'Mystères Joyeux',
    //'Mystères Lumineux',
    //'Mystères Douloureux',
    //'Mystères Glorieux'
  ];

  final List<List<String>> mystereDetails = [
    [
      'L\'Annonciation',
      /*'La Visitation',
      'La Nativité',
      'La Présentation au Temple',
      'Le Recouvrement au Temple',*/
    ],
    /*[
      'Le Baptême au Jourdain',
      'Les Noces de Cana',
      'L\'Annonce du Royaume',
      'La Transfiguration',
      'L\'Institution de l\'Eucharistie'
    ],
    [
      'L\'Agonie de Jésus',
      'La Flagellation',
      'Le Couronnement d\'épines',
      'Le Portement de la Croix',
      'La Crucifixion'
    ],
    [
      'La Résurrection',
      'L\'Ascension',
      'La Pentecôte',
      'L\'Assomption de Marie',
      'Le Couronnement de Marie'
    ]*/
  ];

  // Mappez chaque mystère à son fichier audio correspondant (comme dans votre code original)
  final Map<int, Map<int, String>> audioFiles = {
    0: { // Mystères Joyeux
      0: Assets.audiosAnnonciation,
      /*1: '',
      2: '',
      3: '',
      4: '',*/
    },
    /*1: { // Mystères Lumineux
      0: '',
      1: '',
      2: '',
      3: '',
      4: '',
    },
    2: { // Mystères Douloureux
      0: '',
      1: '',
      2: '',
      3: '',
      4: '',
    },
    3: { // Mystères Glorieux
      0: '',
      1: '',
      2: '',
      3: '',
      4: '',
    },*/
  };

  @override
  void onInit() {
    super.onInit();
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
  }

  // Méthode pour charger un audio
  Future<void> loadAudio(int mystereIndex, int detailIndex) async {
    currentMystereIndex.value = mystereIndex;
    currentMystereDetailIndex.value = detailIndex;
    currentMystereTitle.value = mysteres[mystereIndex];
    currentMystereDetailTitle.value = mystereDetails[mystereIndex][detailIndex];

    // Obtenir le chemin du fichier audio pour le mystère actuel
    final audioPath = audioFiles[mystereIndex]?[detailIndex];

    if (audioPath != null) {
      try {
        // Arrêter l'audio en cours s'il y en a un
        await _audioPlayer.stop();

        // Charger le nouvel audio
        await _audioPlayer.setAsset(audioPath);

        // Réinitialiser le flag de complétion
        isCompleted.value = false;

        // Montrer le mini lecteur
        showMiniPlayer.value = true;
      } catch (e) {
        print("Erreur lors du chargement de l'audio: $e");
      }
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
        print("Erreur lors du redémarrage de l'audio: $e");
        isPlaying.value = false;    // En cas d'erreur, réinitialiser l'état de lecture
      }
    }
    // Sinon, comportement normal play/pause
    else {
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
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

  // Fermer le lecteur
  void closeMiniPlayer() {
    _audioPlayer.stop();
    showMiniPlayer.value = false;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Détruire le service proprement
  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
