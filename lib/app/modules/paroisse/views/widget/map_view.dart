import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_map_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/custom_paroisse_marker_popup.dart';

class MapView extends StatelessWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseMapController>(builder: (controller) {
      return FlutterMap(
        options: controller.mapOptions,
        children: [
          TileLayerWidget(
            options: controller.tileLayerOptions,
          ),
          PopupMarkerLayerWidget(
            options: PopupMarkerLayerOptions(
              markerCenterAnimation: const MarkerCenterAnimation(),
              markers: controller.markers,
              popupSnap: PopupSnap.markerTop,
              popupController: controller.popupLayerController,
              popupBuilder: (BuildContext context, Marker marker) {
                if (marker is CustomParoisseMarker) {
                  return CustomParoisseMarkerPopup(
                    paroisse: controller.paroisseSelected.value,
                  );
                }
                return const Card(child: Text('Not a worship place'));
              },
              popupAnimation:
              const PopupAnimation.fade(duration: Duration(milliseconds: 500)),
            ),
          ),
        ],
      );
    });
  }
}
