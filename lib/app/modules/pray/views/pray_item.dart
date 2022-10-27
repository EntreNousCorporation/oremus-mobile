import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';
import 'package:readmore/readmore.dart';

class PrayItem extends StatelessWidget {
  const PrayItem({Key? key, required this.pray}) : super(key: key);

  final Prayer pray;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      decoration: BoxDecoration(
        color: colorGreenlight2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            //'${DB.getCurrentLanguage() == 'fr' ? pray.title?.fr : pray.title?.en}',
            '${pray.title?.fr}',
            style: TextStyles
                .montserratBold(
              textSize:
              TextSizes.sixteen,
              textColor: colorRed1,
            ),
          ),
          Separators.minimunVertical(),
          ReadMoreText(
            '${pray.content?.fr}',
            colorClickableText: colorGreen,
            style: TextStyles
                .montserratRegular(
              textSize:
              TextSizes.fifteen,
              textColor: colorBlack,
            ),
            trimLines: 5,
            trimMode: TrimMode.Line,
            trimCollapsedText:
            'Tout afficher',
            trimExpandedText:
            '\nRéduire',
            moreStyle: TextStyles
                .montserratSemiBoldItalic(
              textSize:
              TextSizes.fourteen,
              textColor: colorBlack,
            ),
            lessStyle: TextStyles
                .montserratSemiBoldItalic(
              textSize:
              TextSizes.fourteen,
              textColor: colorBlack,
            ),
          ),
        ],
      ),
    );
  }
}
