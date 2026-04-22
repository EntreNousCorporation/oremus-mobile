import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ParoisseMapController extends GetxController {
  ParoisseMapController();

  var paroisseSelected = ContentPlace().obs;

  // Google Map
  var mapController = CustomInfoWindowController();
  GoogleMapController? googleMapController;
  var worshipPlaceMarkers = Rx<Set<Marker>>({});
  List<String> typeMaps = [
    "Plan",
    "Satellite",
  ];
  var typeMapValue = "Plan".obs;
  // ===========================================

  @override
  void onInit() {
    getArguments();
    initControllers();
    super.onInit();
  }

  @override
  void onReady() {
    showInfoWindow();
    super.onReady();
  }

  @override
  void dispose() {
    mapController.dispose();
    if (googleMapController != null) {
      googleMapController!.dispose();
    }
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments);
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  // Méthode pour recentrer la carte sur la paroisse
  void centerOnParoisse() {
    if (googleMapController != null) {
      final position = LatLng(
        paroisseSelected.value.localisation?.latitude ?? 0.0,
        paroisseSelected.value.localisation?.longitude ?? 0.0,
      );

      googleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 17.4746,
          ),
        ),
      );

      // Afficher la fenêtre d'informations après recentrage
      showInfoWindow();
    }
    update();
  }

  initControllers() async {
    log("============= Initializing map markers =============");
    worshipPlaceMarkers.value.clear();
    worshipPlaceMarkers.value.add(
      Marker(
        markerId: MarkerId('${paroisseSelected.value.identifier}'),
        position: LatLng(
          paroisseSelected.value.localisation?.latitude ?? 0.0,
          paroisseSelected.value.localisation?.longitude ?? 0.0,
        ),
        onTap: showInfoWindow,
      ),
    );
  }

  // Méthode pour mettre à jour le type de carte
  void updateTypeMap(String type) {
    typeMapValue.value = type;
    update();
  }

  showInfoWindow() {
    log("============= showInfoWindow =============");
    mapController.addInfoWindow!(
      Container(
        width: Get.width / 1.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorBlack.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête avec image et informations
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image de la paroisse
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: Get.width / 5,
                      height: Get.width / 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        boxShadow: [
                          BoxShadow(
                            color: colorBlack.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: paroisseSelected.value.coverImage?.link != null
                          ? CachedNetworkImage(
                        imageUrl: paroisseSelected.value.coverImage?.link ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => LottieLoadingView(size: Get.width / 6),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/bg_login.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.asset(
                        'assets/images/bg_login.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Informations sur la paroisse
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${paroisseSelected.value.name}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.fifteen,
                            textColor: colorGreenSemiLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (paroisseSelected.value.address?.municipality != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_city,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${paroisseSelected.value.address?.municipality}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.thirteen,
                                    textColor: Colors.grey[700]!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        if (paroisseSelected.value.address?.neighbourhood != null)
                          Row(
                            children: [
                              Icon(
                                Icons.home,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${paroisseSelected.value.address?.neighbourhood}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.thirteen,
                                    textColor: Colors.grey[700]!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur
            Divider(color: Colors.grey[200], height: 1),

            // Bouton d'itinéraire
            InkWell(
              onTap: () {
                mapController.hideInfoWindow!();
                launchMapRoutes();
              },
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions,
                      color: colorGreenSemiLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Obtenir un itinéraire',
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.fourteen,
                        textColor: colorGreenSemiLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      LatLng(
        paroisseSelected.value.localisation?.latitude ?? 0.0,
        paroisseSelected.value.localisation?.longitude ?? 0.0,
      ),
    );
  }

  launchMapRoutes() async {
    String url = "https://www.google.com/maps/dir/?api=1&destination=${paroisseSelected.value.localisation?.latitude ?? 0.0},${paroisseSelected.value.localisation?.longitude ?? 0.0}&travelmode=driving&dir_action=navigate";

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
