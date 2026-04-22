import 'package:get/get.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';

abstract class HistoryMassRequestSelectable {
  Rx<MassRequestResponse> get massRequestSelected;
}