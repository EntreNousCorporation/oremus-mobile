import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';
import 'package:oremusapp/app/modules/pray/views/pray_item.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class MiniMisselScreen extends StatelessWidget {
  const MiniMisselScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PrayController>(
      builder: (controller) {
        return Container(
          color: colorGrey4,
          width: double.infinity,
          child: controller.isDataProcessing.isTrue
              ? Center(
            child: LottieLoadingView(
              size: Get.width / 4,
            ),
          )
              : controller.hasData.isTrue
              ? FadeIn(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              onLoading: controller.onLoading,
              onRefresh: controller.onRefresh,
              header: const CustomClassicHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Container();
                  } else if (mode == LoadStatus.loading) {
                    body = LottieLoadingView();
                  } else if (mode == LoadStatus.failed) {
                    body = Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Text(
                        "Une erreur est survenue lors du chargement",
                        style: TextStyles.montserratMedium(
                          textSize: TextSizes.thirteen,
                          textColor: Colors.red[700]!,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text(
                      "Relâcher pour charger plus de prières",
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.thirteen,
                        textColor: colorGreenSemiLight,
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    body = Visibility(
                      visible: false,
                      child: Column(
                        children: [
                          SizedBox(
                            width: Get.width / 1.7,
                            height: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    colorGreen,
                                    colorGreenSemiLight,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Separators.minimunVertical(),
                          Text(
                            "Aucune donnée à charger",
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.thirteen,
                              textColor: colorBlack,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox(
                    height: 60.0,
                    child: Center(child: body),
                  );
                },
              ),
              physics: const BouncingScrollPhysics(),
              controller: controller.refreshController,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.prayers.length,
                itemBuilder: (context, index) {
                  var pray = controller.prayers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PrayItem(pray: pray),
                  );
                },
              ),
            ),
          )
              : NotFoundScreen(
            message: "Aucune prière trouvée !",
          ),
        );
      },
    );
  }
}
