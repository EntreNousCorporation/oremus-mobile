import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class CustomParoisseMarkerPopup extends StatelessWidget {
  CustomParoisseMarkerPopup({Key? key, required this.paroisse})
      : super(key: key);

  ContentPlace paroisse;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: colorGrey4.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _cardDescription(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Visibility(
              visible: (paroisse.name != null && paroisse.name?.isNotEmpty == true),
              child: Text(
                '${paroisse.name}',
                overflow: TextOverflow.fade,
                softWrap: true,
                maxLines: 2,
                style: TextStyles.montserratSemiBold(
                    textSize: TextSizes.fourteen,
                    textColor: colorGreen),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
            Visibility(
              visible: (paroisse.address != null && paroisse.address?.name != null && paroisse.address?.name?.isNotEmpty == true),
              child: Text(
                '${paroisse.address?.name}',
                style: TextStyles.montserratRegular(
                    textSize: TextSizes.twelve,
                    textColor: colorBlack),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
            Visibility(
              visible: (paroisse.address != null && paroisse.address?.city != null && paroisse.address?.city?.isNotEmpty == true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //const Icon(Icons.location_on_outlined, size: 14,),
                  //const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
                  Text(
                    '${paroisse.address?.city}',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.twelve,
                        textColor: colorBlack),
                  ),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
            Visibility(
              visible: (paroisse.address != null && paroisse.address?.municipality != null && paroisse.address?.municipality?.isNotEmpty == true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //const Icon(Icons.phone, size: 14,),
                  //const Padding(padding: EdgeInsets.symmetric(horizontal: 2.0)),
                  Text(
                    '${paroisse.address?.municipality}',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.twelve,
                        textColor: colorBlack),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomParoisseMarker extends Marker {
  CustomParoisseMarker({required this.paroisse, this.size})
      : super(
    anchorPos: AnchorPos.align(AnchorAlign.top),
    height: size ?? 35,
    width: size ?? 35,
    point: latLng.LatLng(paroisse.localisation?.latitude ?? 0.0, paroisse.localisation?.longitude ?? 0.0),
    builder: (BuildContext ctx) => SvgPicture.asset('assets/images/icon_default_pin.svg', color: colorRed),
  );

  final ContentPlace paroisse;
  double? size;
}
