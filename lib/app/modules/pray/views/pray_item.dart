import 'package:flutter/material.dart';
import 'package:flutter_html_v3/flutter_html.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';
import 'package:oremusapp/app/modules/pray/data/model/prayer.dart';

class PrayItem extends StatelessWidget {
  const PrayItem({Key? key, required this.pray}) : super(key: key);

  final Prayer pray;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrayController>(
      builder: (logic) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: colorGreenlight2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Html(
                  data: pray.title?.fr,
                  style: {
                    '#': Style(
                      fontFamily: 'montserrat_bold',
                      fontSize: FontSize(
                        TextSizes.sixteen,
                      ),
                      margin: Margins.zero,
                    )
                  },
                  //'${DB.getCurrentLanguage() == 'fr' ? pray.title?.fr : pray.title?.en}',
                ),
                Separators.minimunVertical(),
                GestureDetector(
                  onTap: () {
                    pray.isExpand = !(pray.isExpand == true);
                    logic.update();
                  },
                  child: Html(
                    data: pray.content?.fr,
                    style: {
                      '#': Style(
                        fontFamily: 'montserrat_regular',
                        fontSize: FontSize(
                          TextSizes.fifteen,
                        ),
                        maxLines: pray.isExpand == true ? 1000 : 3,
                        textOverflow: TextOverflow.fade,
                        margin: Margins.zero,
                      ),
                    },
                  ),
                ),
                pray.isExpand == true
                    ? OutlinedButton.icon(
                        icon: const Icon(
                          Icons.arrow_upward_rounded,
                          color: colorGreenSemiLight,
                          size: 18,
                        ),
                        label: Text(
                          'Réduire',
                          style: TextStyles.montserratSemiBoldItalic(
                            textSize: TextSizes.twelve,
                            textColor: colorGreenSemiLight,
                          ),
                        ),
                        onPressed: () {
                          pray.isExpand = false;
                          logic.update();
                        },
                      )
                    : TextButton.icon(
                        icon: const Icon(
                          Icons.arrow_downward_rounded,
                          color: colorGreenSemiLight,
                          size: 18,
                        ),
                        label: Text(
                          'Tout afficher',
                          style: TextStyles.montserratSemiBoldItalic(
                            textSize: TextSizes.twelve,
                            textColor: colorGreenSemiLight,
                          ),
                        ),
                        onPressed: () {
                          pray.isExpand = true;
                          logic.update();
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
