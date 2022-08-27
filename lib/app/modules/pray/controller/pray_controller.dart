import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrayController extends GetxController {

  PrayController();

  var unlockBackButton = true.obs;
  var isDataProcessing = false.obs;
  var hasData = false.obs;

  var refreshController = RefreshController();

  @override
  void onInit() {
    super.onInit();
    initPullToRefresh();
  }

  @override
  void onReady() {
    super.onReady();
  }

  initPullToRefresh() {
    refreshController = RefreshController(initialRefresh: false);
  }
}
