import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oremusapp/app/modules/paroisse/controller/map/paroisse_map_controller.dart';

class MapViewGoogle extends StatelessWidget {
  const MapViewGoogle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMapController>(builder: (_) {
      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_.paroisseSelected.value.localisation?.latitude ?? 0.0,
              _.paroisseSelected.value.localisation?.longitude ?? 0.0),
          zoom: 17.4746,
        ),
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        mapToolbarEnabled: false,
        buildingsEnabled: true,
        compassEnabled: false,
        trafficEnabled: true,
        liteModeEnabled: false,
        zoomGesturesEnabled: true,
        markers: _.worshipPlaceMarkers.value,
        mapType: _.typeMapValue.value == 'Plan' ? MapType.normal : MapType.satellite,
        onTap: (LatLng position) {
          _.mapController.value.hideInfoWindow!();
        },
        onCameraMove: (CameraPosition position) {
          _.mapController.value.onCameraMove!();
        },
        onMapCreated: (GoogleMapController controller) {
          _.mapController.value.googleMapController = controller;
          //_.showInfoWindow();
        },
      );
    });
  }
}
