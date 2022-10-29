import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';
import 'package:oremusapp/app/modules/pray/views/pray_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: SafeArea(
        child: GetX<PrayController>(builder: (_) {
          return WillPopScope(
            onWillPop: () async => _.unlockBackButton.value,
            child: KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Container(
                  color: colorGrey4,
                  width: double.infinity,
                  child: Column(
                    children: [
                      _.isDataProcessing.isTrue
                          ? Expanded(
                              child: Center(
                                child: LottieLoadingView(
                                  size: Get.width / 4,
                                ),
                              ),
                            )
                          : _.hasData.isTrue
                              ? Expanded(
                                  child: FadeIn(
                                    duration: const Duration(milliseconds: 500),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0,
                                        bottom: 0,
                                        left: 16,
                                        right: 16,
                                      ),
                                      child: SmartRefresher(
                                        enablePullDown: true,
                                        enablePullUp: true,
                                        onLoading: _.onLoading,
                                        onRefresh: _.onRefresh,
                                        header: const CustomClassicHeader(),
                                        /*header: const WaterDropHeader(
                                          waterDropColor: colorGreenSemiLight,
                                        ),*/
                                        footer: CustomFooter(
                                          builder: (BuildContext context,
                                              LoadStatus? mode) {
                                            Widget body;
                                            if (mode == LoadStatus.idle) {
                                              body = Container();
                                            } else if (mode ==
                                                LoadStatus.loading) {
                                              body = LottieLoadingView();
                                            } else if (mode ==
                                                LoadStatus.failed) {
                                              body = Text(
                                                "Une erreur est survenue lors du chargement",
                                                style:
                                                    TextStyles.montserratBold(
                                                        textSize:
                                                            TextSizes.thirteen,
                                                        textColor: colorBlack),
                                              );
                                            } else if (mode ==
                                                LoadStatus.canLoading) {
                                              body = Text(
                                                "Relacher pour charger plus de prières",
                                                style:
                                                    TextStyles.montserratBold(
                                                        textSize:
                                                            TextSizes.thirteen,
                                                        textColor: colorBlack),
                                              );
                                            } else {
                                              body = Column(
                                                children: [
                                                  SizedBox(
                                                    width: Get.width / 1.7,
                                                    height: 4,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        gradient:
                                                            const LinearGradient(
                                                          begin: Alignment
                                                              .topRight,
                                                          end: Alignment
                                                              .bottomLeft,
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
                                                    style: TextStyles
                                                        .montserratBold(
                                                      textSize:
                                                          TextSizes.thirteen,
                                                      textColor: colorBlack,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return SizedBox(
                                              height: 55.0,
                                              child: Center(child: body),
                                            );
                                          },
                                        ),
                                        physics: const BouncingScrollPhysics(),
                                        controller: _.refreshController,
                                        child: ListView.separated(
                                          padding: const EdgeInsets.only(
                                            top: 16.0,
                                            bottom: 16.0,
                                          ),
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: _.prayers.length,
                                          itemBuilder: (context, index) {
                                            var pray = _.prayers[index];
                                            return PrayItem(pray: pray);
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return Separators.normalVertical();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  child: NotFoundScreen(
                                    message: "Aucune prière trouvée !",
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
