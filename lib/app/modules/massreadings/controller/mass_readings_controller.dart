import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/oremus_logger.dart';
import 'package:oremusapp/app/modules/massreadings/data/model/mass_readings.dart';
import 'package:oremusapp/app/modules/massreadings/data/repository/mass_readings_repository.dart';

class MassReadingsController extends GetxController {
  final MassReadingsRepository massReadingsRepository;

  MassReadingsController({required this.massReadingsRepository});

  final isLoading = false.obs;
  final hasError = false.obs;
  final Rxn<MassReadings> massReadings = Rxn<MassReadings>();

  @override
  void onReady() {
    loadToday();
    super.onReady();
  }

  /// Charge les lectures du jour. Met a jour les etats loading / error afin
  /// que la vue affiche un spinner, le contenu, ou un etat "indisponible".
  Future<void> loadToday() async {
    isLoading(true);
    hasError(false);
    try {
      massReadings.value = await massReadingsRepository.getToday();
    } catch (e) {
      hasError(true);
      OremusLogger.error("loadToday mass readings failed => ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
}
