import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/modules/reportproblem/data/model/report_problem_data.dart';
import 'package:oremusapp/app/modules/reportproblem/data/repository/interface_report_problem_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';
import 'package:oremusapp/app/remote/custom_exception.dart';
import 'package:oremusapp/app/remote/error_response.dart';

class ReportProblemRepository implements IReportProblemRepository {
  final ApiClient _apiClient;

  ReportProblemRepository(this._apiClient);

  @override
  Future<List<ReportProblemTypeData>> getReportProblemTypes() async {
    Response response = await _apiClient.doRequest(
      endpoint: "/report-problem-types",
      method: HttpMethod.get,
    );
    log('resp getMassRequestPrice => ${response.statusCode}');

    if (response.statusCode != 200) {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    } else {
      return (jsonDecode(response.bodyString.toString()) as List)
          .map((i) => ReportProblemTypeData.fromJson(i))
          .toList();
    }
  }

  @override
  Future<ReportProblemData> reportProblem({required ReportProblemData request}) async {
    Response response = await _apiClient.doRequest(
      endpoint: "/report-problems",
      method: HttpMethod.post,
      body: request.toJson(),
    );
    log('resp sendMassRequest => ${response.statusCode}');

    if (response.statusCode! >= 200 && response.statusCode! <= 205) {
      return ReportProblemData();
    } else {
      var e = ErrorResponse.fromJson(jsonDecode(response.bodyString.toString()));
      throw CustomException(e.debugMessage, e.status);
    }
  }
}
