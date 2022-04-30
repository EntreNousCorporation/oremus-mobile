import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:oremusapp/app/modules/home/data/model/type_menu.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/repository/paroisse_repository.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class ParoisseMenuDetailController extends GetxController {
  final ParoisseRepository paroisseRepository;

  ParoisseMenuDetailController({
    required this.paroisseRepository,
  });

  var code = ''.obs;
  var paroisseSelected = ContentPlace().obs;
  var indexDaySelected = 0.obs;
  var openingTime = OpeningTime().obs;

  RxList<TypeMenu> menus = RxList<TypeMenu>([]);
  RxList<LiturgicalCelebrationResponse> liturgicalCelebrations = RxList<LiturgicalCelebrationResponse>([]);

  RxList<LiturgicalCelebrationResponse> massesNotRecurrent = RxList<LiturgicalCelebrationResponse>([]);
  RxList<LiturgicalCelebrationResponse> massesRecurrent = RxList<LiturgicalCelebrationResponse>([]);
  RxList<LiturgicalCelebrationResponse> massess = RxList<LiturgicalCelebrationResponse>([]);

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      code.value = Get.arguments[0];
      paroisseSelected.value = ContentPlace.fromJson(jsonDecode(Get.arguments[1]));
      var masses = getMasses(Get.arguments[2]);
      if (code.value == 'HM') {
        massess.value = masses;
        massesNotRecurrent.value = masses.where((element) => (element.isRecurrent == false)/* && (Jiffy(element.startDate).isAfter(Jiffy()))*/).toList();
        massesRecurrent.value = masses.where((element) => (element.isRecurrent == true)).toList();
        /*for (var element in liturgicalCelebrations.value) {
          element.openingTime?.sort((a, b) => a.dayOfWeek.toString().compareTo(b.dayOfWeek.toString()));
        }*/
        log('massesNotRecurrent => ${massesNotRecurrent.length}');
        log('massesRecurrent => ${massesRecurrent.length}');
      }
      if (code.value == 'HC') {
        liturgicalCelebrations.value = masses;
        for (var element in liturgicalCelebrations.value) {
          element.openingTime?.sort((a, b) => a.dayOfWeek.toString().compareTo(b.dayOfWeek.toString()));
        }
      }
      log('paroisseSelected ==> ${paroisseSelected.value.identifier}');
    }
  }

  List<LiturgicalCelebrationResponse> getMasses(String massesToConverted) {
    Iterable l = json.decode(massesToConverted);
    return l.map((model) => LiturgicalCelebrationResponse.fromJson(model)).toList();
  }

  getTime(String timeToConverted) {
    var hour = timeToConverted.split(':').first;
    var minutes = timeToConverted.split(':')[1];
    return '${hour}h$minutes';
  }

  getTypeTitle(String code) {
    switch (code) {
      case 'HM':
        return 'Horaires des messes';
      case 'HC':
        return 'Horaires des confessions';
      case 'HB':
        return 'Horaires des bureaux';
      case 'AM':
        return 'Activités & mouvements';
      case 'EP':
        return 'Equipe presbytérale';
    }
  }

  getTypeMessage(String code) {
    switch (code) {
      case 'HM':
      case 'HC':
      case 'HB':
        return 'Horaires non disponible\nRéessayez plus tard svp';
      case 'AM':
      case 'EP':
        return 'Aucune information trouvée';
    }
  }

  goToMap() {
    Get.toNamed(
      Routes.PAROISSE_MAP,
      arguments: jsonEncode(paroisseSelected.value.toJson()),
    );
  }
}
