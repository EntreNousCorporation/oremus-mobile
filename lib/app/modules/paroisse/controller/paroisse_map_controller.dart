import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/custom_paroisse_marker_popup.dart';

class ParoisseMapController extends GetxController {
  ParoisseMapController();

  var paroisseSelected = ContentPlace().obs;

  RxList<CustomParoisseMarker> markers = RxList<CustomParoisseMarker>([]);
  var mapController = MapController().obs;
  final PopupController popupLayerController = PopupController();
  late MapOptions mapOptions;
  late TileLayerOptions tileLayerOptions;

  @override
  void onInit() {
    getArguments();
    initControllers();
    super.onInit();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(jsonDecode(Get.arguments));
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  initControllers() {
    mapOptions = MapOptions(
      controller: mapController.value,
      center: latLng.LatLng(
          paroisseSelected.value.localisation?.latitude ?? 5.357314,
          paroisseSelected.value.localisation?.longitude ?? -4.008363,
      ),
      zoom: 12.0,
      interactiveFlags: InteractiveFlag.all,
      onTap: (tapPosition, latlong) => popupLayerController.hideAllPopups(),
    );

    tileLayerOptions = TileLayerOptions(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c'],
      fastReplace: true,
      attributionAlignment: Alignment.bottomLeft,
      attributionBuilder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "© Oremus",
            style: TextStyles.montserratMedium(
                textSize: TextSizes.eighteen, textColor: colorBlack),
          ),
        );
      },
    );

    markers.add(CustomParoisseMarker(paroisse: paroisseSelected.value));
  }
}
