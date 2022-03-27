import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/home/data/model/menu_item.dart';

class MenuGridItem extends StatelessWidget {
  MenuGridItem({required this.item, Key? key}) : super(key: key);

  MenuItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius:
        BorderRadius.circular(10.0),
        elevation: 10,
        color: colorWhite,
        shadowColor:
        colorGrey2.withOpacity(0.5),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [
            Image.asset('${item.icon}', height: Get.width / 8),
            Separators.minimunVertical(),
            Padding(
              padding: const EdgeInsets
                  .symmetric(
                  horizontal: 8.0),
              child: Text(
                '${item.libelle}',
                maxLines: 2,
                overflow: TextOverflow
                    .ellipsis,
                style: TextStyles
                    .montserratBold(
                    textSize:
                    TextSizes
                        .thirteen,
                    textColor:
                    colorBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
