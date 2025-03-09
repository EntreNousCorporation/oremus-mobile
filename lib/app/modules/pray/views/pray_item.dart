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
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: colorGreenlight2,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prayer title with accent bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    decoration: const BoxDecoration(
                      color: colorGreenlight2,
                      border: Border(
                        left: BorderSide(
                          color: colorGreenSemiLight,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Html(
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
                          ),
                        ),
                        Visibility(
                          visible: false,
                          child: GestureDetector(
                            onTap: () {
                              pray.isExpand = !(pray.isExpand == true);
                              logic.update();
                            },
                            child: Icon(
                              pray.isExpand == true
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: colorGreenSemiLight,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Prayer content
                  GestureDetector(
                    onTap: () {
                      pray.isExpand = !(pray.isExpand == true);
                      logic.update();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Html(
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

                          // Show more/less button with subtle divider
                          GestureDetector(
                            onTap: () {
                              pray.isExpand = !(pray.isExpand == true);
                              logic.update();
                            },
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  height: 1,
                                  color: Colors.black.withValues(alpha: 0.05),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      pray.isExpand == true
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      color: colorGreenSemiLight,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      pray.isExpand == true ? 'Réduire' : 'Tout afficher',
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.thirteen,
                                        textColor: colorGreenSemiLight,
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
