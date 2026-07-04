import 'package:oremusapp/app/modules/massreadings/data/model/mass_readings.dart';

abstract class IMassReadingsRepository {
  /// Lectures de la messe du jour courant.
  Future<MassReadings> getToday();
}
