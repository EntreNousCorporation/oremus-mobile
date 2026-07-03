import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/massreadings/data/model/mass_readings.dart';
import 'package:oremusapp/app/modules/massreadings/data/repository/interface_mass_readings_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class MassReadingsRepository implements IMassReadingsRepository {
  final ApiClient _apiClient;

  MassReadingsRepository(this._apiClient);

  @override
  Future<MassReadings> getToday() async {
    // Endpoint public (pas de Bearer requis).
    Response response = await _apiClient.doRequest(
      endpoint: "/mass-readings/today",
      method: HttpMethod.get,
      useBearer: false,
    );

    if (response.statusCode != 200) {
      throw Exception(json.encode(response.data));
    }
    return MassReadings.fromJson(response.data);
  }
}
