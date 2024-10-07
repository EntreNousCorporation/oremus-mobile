import 'package:get/get.dart';
import 'package:oremusapp/app/modules/reportproblem/controller/report_problem_controller.dart';
import 'package:oremusapp/app/modules/reportproblem/data/repository/report_problem_repository.dart';
import 'package:oremusapp/app/remote/api_client.dart';

class ReportProblemBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      ReportProblemController(
        reportProblemRepository: ReportProblemRepository(ApiClientImpl()),
      ),
    );
  }
}
