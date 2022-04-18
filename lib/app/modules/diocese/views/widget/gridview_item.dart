import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class GridviewItem extends StatelessWidget {
  const GridviewItem({Key? key, required this.diocese}) : super(key: key);

  final ContentPlace diocese;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10,
        color: colorWhite,
        shadowColor: colorGrey2.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: SizedBox(
                height: Get.width/3.7,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/diocese_placeholder.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Separators.minimunVertical(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${diocese.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.montserratBold(
                          textSize: TextSizes.eleven, textColor: colorBlack),
                    ),
                  ),
                  Separators.minimunHorizontal(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 18,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: colorGrey1,
                        ),
                        child: Text(
                          'Voir détails',
                          style: TextStyles.montserratBold(
                              textSize: TextSizes.eight, textColor: colorBlack),
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
    );
  }
}
