import 'package:oremusapp/app/modules/reportproblem/data/model/report_problem_data.dart';

abstract class IReportProblemRepository {
  //For API
  Future<List<ReportProblemTypeData>> getReportProblemTypes();
  Future<ReportProblemData> reportProblem({required ReportProblemData request});
}
