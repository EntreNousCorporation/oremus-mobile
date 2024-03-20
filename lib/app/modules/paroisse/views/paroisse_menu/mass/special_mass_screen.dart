import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_mass_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:super_banners/super_banners.dart';

class SpecialMassScreen extends StatelessWidget {
  const SpecialMassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMassController>(builder: (logic) {
      if (logic.isSpecialMassDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasSpecialMassData.isTrue) {
          return FadeIn(
              duration: const Duration(milliseconds: 500),
              child: SmartRefresher(
                controller: logic.refreshNotRecurrentController,
                onRefresh: logic.onSpecialMassesRefresh,
                header: const CustomClassicHeader(),
                child: GroupedListView<LiturgicalCelebrationResponse?, String>(
                  padding: const EdgeInsets.all(16.0),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  elements: logic.specialMasses,
                  useStickyGroupSeparators: false,
                  groupBy: (liturgicalCelebration) =>
                      liturgicalCelebration?.startDate ?? '',
                  groupHeaderBuilder: (liturgicalCelebration) => Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: colorGreenSemiLight.withOpacity(0.4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${liturgicalCelebration?.name}',
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.seventeen,
                              ),
                            ),
                            Separators.minimunVertical(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  getDate(liturgicalCelebration?.startDate ?? ''),
                                  style: TextStyles.montserratSemiBold(
                                    textSize: TextSizes.twelve,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      logic.isMassExpired(liturgicalCelebration)
                          ? Positioned(
                        right: 0,
                        child: CornerBanner(
                          bannerPosition: CornerBannerPosition.topRight,
                          bannerColor: colorRed.withOpacity(0.85),
                          shadowColor: colorBlack.withOpacity(0.8),
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              'Passée',
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.montserratSemiBold(
                                textSize: TextSizes.nine,
                                textColor: colorWhite,
                              ),
                            ),
                          ),
                        ))
                          : const SizedBox.shrink(),
                    ],
                  ),
                  order: GroupedListOrder.ASC,
                  itemBuilder: (c, liturgicalCelebration) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            getHour(liturgicalCelebration?.startDate ?? ''),
                            style: TextStyles.montserratMedium(
                              textColor: colorBlack,
                              textSize: TextSizes.thirteen,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ));
        } else {
          return NotFoundScreen(
              message: 'Horaires non disponibles pour l\'instant');
        }
      }
    });
  }
}
