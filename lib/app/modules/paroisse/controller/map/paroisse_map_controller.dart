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
import 'package:url_launcher/url_launcher.dart';

class ParoisseMapController extends GetxController {
  ParoisseMapController();

  var paroisseSelected = ContentPlace().obs;

  //Google Map
  //Completer<GoogleMapController> controller = Completer();
  var mapController = CustomInfoWindowController();
  var worshipPlaceMarkers = Rx<Set<Marker>>({});
  List<String> typeMaps = [
    "Plan",
    "Satellite",
  ];
  var typeMapValue = "Plan".obs;
  //===========================================

  @override
  void onInit() {
    getArguments();
    initControllers();
    super.onInit();
  }
  //https://goo.gl/maps/EcqfGFCj7HUjaByD6
  //https://www.google.com/maps/dir/?api=1&destination=5.3615683,-3.9614188,19z&travelmode=driving&dir_action=navigate
  //https://www.google.com/maps/dir/?api=1&destination=5.361981170134402,-3.960254155399859&travelmode=driving&dir_action=navigate
  @override
  void onReady() {
    showInfoWindow();
    super.onReady();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  getArguments() {
    if (Get.arguments != null) {
      paroisseSelected.value = ContentPlace.fromJson(Get.arguments);
      log('==> ${paroisseSelected.value.identifier}');
    }
  }

  getIcon() async {
    return await BitmapDescriptor.fromAssetImage(
        createLocalImageConfiguration(Get.context!),
        "assets/images/icon_default_pin.svg");
  }

  initControllers() async {
    /*await MarkerIcon.svgAsset(
      assetName: 'assets/images/icon_default_pin.svg',
      context: Get.context!,
      size: 40,
    ).then((bitmap) {
      log("message 2");
      worshipPlaceMarkers.value.add(
        Marker(
            markerId: MarkerId('${paroisseSelected.value.identifier}'),
            //icon: bitmap, //todo - pourquoi le marker n'est pas mis à jour au 1er lancement de la map
            position: LatLng(paroisseSelected.value.localisation?.latitude ?? 0.0,
                paroisseSelected.value.localisation?.longitude ?? 0.0),
            onTap: () {
              mapController.value.addInfoWindow!(
                SizedBox(
                  width: Get.width / 1.2,
                  child: Material(
                    borderRadius: BorderRadius.circular(10.0),
                    elevation: 10,
                    color: colorWhite,
                    shadowColor: colorGrey2.withValues(alpha: 0.5),
                    child: Column(
                      children: [
                        Separators.normalVertical(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Material(
                                borderRadius: BorderRadius.circular(10.0),
                                elevation: 10,
                                color: colorWhite,
                                shadowColor: colorGrey2.withValues(alpha: 0.8),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0)),
                                  child: paroisseSelected
                                      .value.coverImage?.link !=
                                      null
                                      ? CachedNetworkImage(
                                    width: Get.width / 5,
                                    height: Get.width / 5,
                                    imageUrl: paroisseSelected
                                        .value.coverImage?.link ??
                                        '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        LottieLoadingView(
                                            size: Get.width / 6),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                  )
                                      : Image.asset(
                                    'assets/images/bg_login.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Separators.normalHorizontal(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${paroisseSelected.value.name}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.montserratMedium(
                                          textSize: TextSizes.eighteen,
                                          textColor: colorBlack),
                                    ),
                                    Text(
                                      '${paroisseSelected.value.address?.municipality}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.montserratRegular(
                                          textSize: TextSizes.sixteen,
                                          textColor: colorGrey1),
                                    ),
                                    Text(
                                      '${paroisseSelected.value.address?.neighbourhood}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorGrey1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Separators.normalVertical(),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                              backgroundColor: colorGreenSemiLight),
                          icon: const Icon(
                            Icons.pin_drop_rounded,
                            color: colorWhite,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              'Voir itinéraire',
                              style: TextStyles.montserratMedium(
                                  textSize: TextSizes.sixteen,
                                  textColor: colorWhite),
                            ),
                          ),
                          onPressed: () {
                            mapController.value.hideInfoWindow!();
                            showCustomDialog(Get.context!,
                                message:
                                "Vous serez redirigés vers une autre application",
                                negativeLabel: 'Annuler',
                                negativeCallBack: () {},
                                positiveLabel: 'Continuer', positiveCallBack: () {
                                  launchMapRoutes();
                                });
                          },
                        ),
                        Separators.normalVertical(),
                      ],
                    ),
                  ),
                ),
                LatLng(paroisseSelected.value.localisation?.latitude ?? 0.0,
                    paroisseSelected.value.localisation?.longitude ?? 0.0),
              );
            }),
      );
    });*/

    log("============= showInfoWindow 1 =============");
    worshipPlaceMarkers.value.clear();
    worshipPlaceMarkers.value.add(
      Marker(
          markerId: MarkerId('${paroisseSelected.value.identifier}'),
          //icon: bitmap, //todo - pourquoi le marker n'est pas mis à jour au 1er lancement de la map
          position: LatLng(paroisseSelected.value.localisation?.latitude ?? 0.0,
              paroisseSelected.value.localisation?.longitude ?? 0.0),
          onTap: showInfoWindow),
    );
  }

  showInfoWindow() {
    log("============= showInfoWindow ============= ${paroisseSelected.value.localisation?.longitude.toString()}");
    mapController.addInfoWindow!(
      SizedBox(
        width: Get.width / 1.2,
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 10,
          color: colorWhite,
          shadowColor: colorGrey2.withValues(alpha: 0.5),
          child: Column(
            children: [
              Separators.normalVertical(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      borderRadius: BorderRadius.circular(10.0),
                      elevation: 10,
                      color: colorWhite,
                      shadowColor: colorGrey2.withValues(alpha: 0.8),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10.0)),
                        child: paroisseSelected.value.coverImage?.link != null
                            ? CachedNetworkImage(
                                width: Get.width / 5,
                                height: Get.width / 5,
                                imageUrl:
                                    paroisseSelected.value.coverImage?.link ??
                                        '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    LottieLoadingView(size: Get.width / 6),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )
                            : Image.asset(
                                'assets/images/bg_login.jpg',
                                width: Get.width / 5,
                                height: Get.width / 5,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Separators.normalHorizontal(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${paroisseSelected.value.name}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.montserratMedium(
                                textSize: TextSizes.eighteen,
                                textColor: colorBlack),
                          ),
                          Text(
                            '${paroisseSelected.value.address?.municipality}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.montserratRegular(
                                textSize: TextSizes.sixteen,
                                textColor: colorGrey1),
                          ),
                          Text(
                            '${paroisseSelected.value.address?.neighbourhood}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.sixteen,
                              textColor: colorGrey1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Separators.normalVertical(),
              TextButton.icon(
                style:
                    TextButton.styleFrom(backgroundColor: colorGreenSemiLight),
                icon: const Icon(
                  Icons.pin_drop_rounded,
                  color: colorWhite,
                ),
                label: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    'Voir itinéraire',
                    style: TextStyles.montserratMedium(
                        textSize: TextSizes.sixteen, textColor: colorWhite),
                  ),
                ),
                onPressed: () {
                  mapController.hideInfoWindow!();
                  launchMapRoutes();
                },
              ),
              Separators.normalVertical(),
            ],
          ),
        ),
      ),
      LatLng(paroisseSelected.value.localisation?.latitude ?? 0.0,
          paroisseSelected.value.localisation?.longitude ?? 0.0),
    );
  }

  launchMapRoutes() async {
    //String url = "https://www.google.com/maps/dir/?api=1&origin=${paroisseSelected.value.localisation?.latitude ?? 0.0},${paroisseSelected.value.localisation?.longitude ?? 0.0}&destination=${paroisseSelected.value.localisation?.latitude ?? 0.0},${paroisseSelected.value.localisation?.longitude ?? 0.0}&travelmode=driving&dir_action=navigate";

    String url = "https://www.google.com/maps/dir/?api=1&destination=${paroisseSelected.value.localisation?.latitude ?? 0.0},${paroisseSelected.value.localisation?.longitude ?? 0.0}&travelmode=driving&dir_action=navigate";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
