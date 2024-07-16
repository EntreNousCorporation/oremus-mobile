import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/db/db.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/search_criteria.dart';
import 'package:oremusapp/app/routes/app_pages.dart';

class FilterMassRequestDateController extends GetxController {

  FilterMassRequestDateController();

  RxList<TypeData> massRequestTypes = RxList<TypeData>([]);
  RxList<TypeData> massRequestTypesTemp = RxList<TypeData>([]);
  var massRequestTypeSelected = TypeData().obs;
  var unlockBackButton = true.obs;

  var isMassRequestDataProcessing = false.obs;
  var hasMassRequestData = false.obs;

  late TextEditingController typeMassRequestSearchController;

  var isMassRequestSearchFieldEmpty = true.obs;

  var searchCriteria = SearchCriteria().obs;
  var enabledApplyButton = false.obs;


  RxList<PriceData> datesChoosen = RxList<PriceData>([]);
  RxList<LiturgicalCelebrationResponse> worshipHours = RxList<LiturgicalCelebrationResponse>([]);

  RxList<LiturgicalCelebrationResponse> worshipRecurrentHoursTemp = RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipRecurrentHours = RxList<PriceData>([]);

  RxList<LiturgicalCelebrationResponse> worshipSpecialHoursTemp = RxList<LiturgicalCelebrationResponse>([]);
  RxList<PriceData> worshipSpecialHours = RxList<PriceData>([]);


  String jsonString = '''
  [
    {
        "identifier": 6,
        "createdAt": "2024-03-20T12:09:52",
        "updatedAt": "2024-03-20T12:09:52",
        "createdBy": "info@oremus.ci",
        "modifiedBy": "info@oremus.ci",
        "name": "Messes en semaine",
        "slots": [],
        "type": {
            "identifier": 1,
            "createdAt": "2024-02-18T21:47:17",
            "updatedAt": "2024-07-12T12:25:34",
            "code": "MASS",
            "translate": {
                "identifier": 1236,
                "createdAt": "2024-07-12T12:25:34",
                "updatedAt": "2024-07-12T12:25:34",
                "fr": "Messe",
                "en": "Mass"
            }
        },
        "isRecurrent": true,
        "openingTime": [
            {
                "identifier": 5,
                "createdAt": "2024-03-20T12:09:52",
                "updatedAt": "2024-03-20T12:09:52",
                "createdBy": "info@oremus.ci",
                "modifiedBy": "info@oremus.ci",
                "dayOfWeek": 0,
                "slots": [
                    {
                        "identifier": 7,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "06:00:00",
                        "endTime": "06:30:00"
                    },
                    {
                        "identifier": 9,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "12:00:00",
                        "endTime": "13:00:00"
                    },
                    {
                        "identifier": 8,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "18:00:00",
                        "endTime": "19:00:00"
                    }
                ]
            },
            {
                "identifier": 3,
                "createdAt": "2024-03-20T12:09:52",
                "updatedAt": "2024-03-20T12:09:52",
                "createdBy": "info@oremus.ci",
                "modifiedBy": "info@oremus.ci",
                "dayOfWeek": 1,
                "slots": [
                    {
                        "identifier": 4,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "06:00:00",
                        "endTime": "06:30:00"
                    },
                    {
                        "identifier": 3,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "12:00:00",
                        "endTime": "13:00:00"
                    }
                ]
            },
            {
                "identifier": 4,
                "createdAt": "2024-03-20T12:09:52",
                "updatedAt": "2024-03-20T12:09:52",
                "createdBy": "info@oremus.ci",
                "modifiedBy": "info@oremus.ci",
                "dayOfWeek": 2,
                "slots": [
                    {
                        "identifier": 5,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "06:00:00",
                        "endTime": "06:45:00"
                    },
                    {
                        "identifier": 6,
                        "createdAt": "2024-03-20T12:09:52",
                        "updatedAt": "2024-03-20T12:09:52",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "12:00:00",
                        "endTime": "12:45:00"
                    }
                ]
            }
        ]
    },
    {
        "identifier": 24,
        "createdAt": "2024-05-17T15:20:36",
        "updatedAt": "2024-05-17T15:20:36",
        "createdBy": "info@oremus.ci",
        "modifiedBy": "info@oremus.ci",
        "name": "Confession",
        "slots": [],
        "type": {
            "identifier": 2,
            "createdAt": "2024-02-18T21:47:17",
            "updatedAt": "2024-07-12T12:25:34",
            "code": "CONFESSION",
            "translate": {
                "identifier": 1237,
                "createdAt": "2024-07-12T12:25:34",
                "updatedAt": "2024-07-12T12:25:34",
                "fr": "Confession",
                "en": "Confession"
            }
        },
        "isRecurrent": true,
        "openingTime": [
            {
                "identifier": 7,
                "createdAt": "2024-05-17T15:20:36",
                "updatedAt": "2024-05-17T15:20:36",
                "createdBy": "info@oremus.ci",
                "modifiedBy": "info@oremus.ci",
                "dayOfWeek": 5,
                "slots": [
                    {
                        "identifier": 51,
                        "createdAt": "2024-05-17T15:20:36",
                        "updatedAt": "2024-05-17T15:20:36",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "14:00:00"
                    }
                ]
            }
        ]
    },
    {
        "identifier": 7,
        "createdAt": "2024-03-20T12:11:18",
        "updatedAt": "2024-03-20T12:11:18",
        "createdBy": "info@oremus.ci",
        "modifiedBy": "info@oremus.ci",
        "name": "Messes Dominicale",
        "slots": [],
        "type": {
            "identifier": 1,
            "createdAt": "2024-02-18T21:47:17",
            "updatedAt": "2024-07-12T12:25:34",
            "code": "MASS",
            "translate": {
                "identifier": 1236,
                "createdAt": "2024-07-12T12:25:34",
                "updatedAt": "2024-07-12T12:25:34",
                "fr": "Messe",
                "en": "Mass"
            }
        },
        "isRecurrent": true,
        "openingTime": [
            {
                "identifier": 6,
                "createdAt": "2024-03-20T12:11:18",
                "updatedAt": "2024-03-20T12:11:18",
                "createdBy": "info@oremus.ci",
                "modifiedBy": "info@oremus.ci",
                "dayOfWeek": 6,
                "slots": [
                    {
                        "identifier": 11,
                        "createdAt": "2024-03-20T12:11:18",
                        "updatedAt": "2024-03-20T12:11:18",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "06:00:00",
                        "endTime": "07:30:00"
                    },
                    {
                        "identifier": 12,
                        "createdAt": "2024-03-20T12:11:18",
                        "updatedAt": "2024-03-20T12:11:18",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "08:00:00",
                        "endTime": "10:00:00"
                    },
                    {
                        "identifier": 10,
                        "createdAt": "2024-03-20T12:11:18",
                        "updatedAt": "2024-03-20T12:11:18",
                        "createdBy": "info@oremus.ci",
                        "modifiedBy": "info@oremus.ci",
                        "startTime": "18:00:00",
                        "endTime": "19:00:00"
                    }
                ]
            }
        ]
    }
] ''';

  @override
  void onInit() {
    getArguments();
    initControllers();
    super.onInit();
  }

  List<PriceData> transformWorshipSpecialHours(List<dynamic> jsonData) {
    Map<String, List<Map<String, String>>> groupedSlots = {};

    for (var event in jsonData) {
      String fullDate = event['startDate'];
      String formattedDate = fullDate.split('T')[0];
      event['startDate'] = formattedDate;
    }

    for (var event in jsonData) {
      String day = event['startDate'];
      if (!groupedSlots.containsKey(day)) {
        groupedSlots[day] = [];
      }
      for (var slot in event['slots']) {
        groupedSlots[day]!.add({
          "startTime": slot['startTime'] ?? "",
          "endTime": slot['endTime'] ?? ""
        });
      }
    }

    List<Map<String, dynamic>> result = groupedSlots.entries.map((entry) {
      return {
        "day": entry.key,
        "slots": entry.value
      };
    }).toList();

    String outputJson = jsonEncode(result);
    return (jsonDecode(outputJson) as List)
        .map((i) => PriceData.fromJson(i))
        .toList();
  }

  List<PriceData> transformWorshipRecurrentHours(List<dynamic> jsonData) {
    Map<String, List<Map<String, dynamic>>> groupedByDay = {};

    for (var item in jsonData) {
      for (var openingTime in item['openingTime']) {
        String dayOfWeek = openingTime['dayOfWeek'].toString();

        if (!groupedByDay.containsKey(dayOfWeek)) {
          groupedByDay[dayOfWeek] = [];
        }

        for (var slot in openingTime['slots']) {
          groupedByDay[dayOfWeek]?.add({
            "identifier": slot['identifier'],
            "createdAt": slot['createdAt'],
            "updatedAt": slot['updatedAt'],
            "createdBy": slot['createdBy'],
            "modifiedBy": slot['modifiedBy'],
            "startTime": slot['startTime'],
            "endTime": slot['endTime'],
          });
        }
      }
    }

    List<Map<String, dynamic>> transformedData = groupedByDay.entries.map((entry) {
      return {
        "dayOfWeek": entry.key,
        "slots": entry.value,
      };
    }).toList();

    // Trier les jours de la semaine
    transformedData.sort((a, b) => int.parse(a['dayOfWeek']).compareTo(int.parse(b['dayOfWeek'])));

    //log(json.encode(transformedData));
    String outputJson = jsonEncode(transformedData);

    return (jsonDecode(outputJson) as List)
        .map((i) => PriceData.fromJson(i))
        .toList();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      worshipHours.value = Get.arguments;
      worshipRecurrentHoursTemp.value = worshipHours.where((element) => element.isRecurrent == true).toList();
      worshipSpecialHoursTemp.value = worshipHours.where((element) => element.isRecurrent == false && (Jiffy.parse(element.startDate ?? Jiffy.now().format(), pattern: AppConstants.TIME_ZONE_FORMAT).isBefore(Jiffy.now().add(hours: 24)))).toList();

      List<dynamic> jsonData1 = jsonDecode(jsonEncode(worshipRecurrentHoursTemp));
      //List<dynamic> jsonData = jsonDecode(jsonString);
      worshipRecurrentHours.value = transformWorshipRecurrentHours(jsonData1);
      log('worshipRecurrentHours ::: ${jsonEncode(worshipRecurrentHours)}');

      List<dynamic> jsonData2 = jsonDecode(jsonEncode(worshipSpecialHoursTemp));
      //List<dynamic> jsonData = jsonDecode(jsonString);
      worshipSpecialHours.value = transformWorshipSpecialHours(jsonData2);
      log('worshipSpecialHours ::: ${jsonEncode(worshipSpecialHours)}');
    }
  }

  initControllers() {
    typeMassRequestSearchController = TextEditingController(text: '');
  }

  disposeControllers() {
    typeMassRequestSearchController.dispose();
  }

  doLogout() {
    DB.saveData(AppConstants.KEY_USER_LOG_INFOS, null);
    Get.deleteAll(force: true);
    Get.offAllNamed(Routes.SIGNIN);
  }

  resetControllers() {
    searchCriteria.value.typeOfMassRequest = null;
  }

  doResetFilter() {
    massRequestTypeSelected.value = TypeData();
    searchCriteria.value.typeOfMassRequest = null;
    resetControllers();
    canDoApplyAction();
    hideKeyboard();
    Get.delete<FilterMassRequestDateController>(force: true);
  }

  onMassRequestTypeDataSelected(TypeData pt) {
    if (massRequestTypeSelected.value == pt) {
      massRequestTypeSelected.value = TypeData();
      searchCriteria.value.typeOfMassRequest = null;
    } else {
      massRequestTypeSelected.value = pt;
      searchCriteria.value.typeOfMassRequest = pt.code;
    }
    canDoApplyAction();
  }

  int getCriteriaCount() {
    var sum = 0;
    if (searchCriteria.value.typeOfMassRequest != null && searchCriteria.value.typeOfMassRequest?.isNotEmpty == true) {
      sum += 1;
    }
    return sum;
  }

  canDoApplyAction() {
    enabledApplyButton.value = searchCriteria.value.isMassRequestCriteriaEmpty == false;
  }

  goBackToMassRequestHistory() {
    //searchCriteria.value.countCriteria = getCriteriaCount();
    Get.back(result: datesChoosen);
  }

  updateMassRequestTypeFilter(String value) {
    massRequestTypesTemp.value = massRequestTypes.where((p) => p.name?.fr?.toLowerCase().contains(value.toLowerCase()) == true).toList();
  }

  //SEARCH SECTION
  resetMassRequestTypeSearch() {
    typeMassRequestSearchController.clear();
    massRequestTypesTemp.value = massRequestTypes.value;
    hideKeyboard();
  }
}
