import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/paroisse_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseScreen extends StatelessWidget {
  const ParoisseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<ParoisseController>(
            initState: (state) {},
            builder: (_) {
              return WillPopScope(
                onWillPop: () async => false,
                child: KeyboardDismisser(
                  child: SmartRefresher(
                    controller: _.refreshController,
                    onRefresh: _.onRefresh,
                    child: Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: Container(
                        color: colorGrey4,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 16, bottom: 0, left: 16, right: 16),
                              child: Row(
                                children: [
                                  Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        elevation: 10,
                                        color: colorWhite,
                                        shadowColor:
                                            colorGrey2.withOpacity(0.5),
                                        child: SizedBox(
                                          height: (Get.width / 9),
                                          width: (Get.width / 9),
                                          child: const Icon(
                                            Icons.arrow_back_ios_rounded,
                                            color: colorBlack,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: Separators.normalHorizontal(),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: (Get.width / 9),
                                      child: const SearchWidget(),
                                    ),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: Separators.normalHorizontal(),
                                  ),
                                  Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10.0),
                                        elevation: 10,
                                        color: colorWhite,
                                        shadowColor: colorGrey2.withOpacity(0.5),
                                        child: SizedBox(
                                          height: (Get.width / 9),
                                          width: (Get.width / 9),
                                          child: const Icon(
                                            Icons.filter_list_rounded,
                                            color: colorPurpleLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Separators.maximumVertical(),
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
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0,
                                                bottom: 0,
                                                left: 16,
                                                right: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: ListView.builder(
                                                      //physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: false,
                                                      itemCount:
                                                          _.paroisses.length,
                                                      itemBuilder:
                                                          (builder, index) {
                                                        var paroisse =
                                                            _.paroisses[index];
                                                        return ParoisseItem(
                                                          paroisse: paroisse,
                                                          index: index,
                                                        );
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: NotFoundScreen(
                                        message: "Aucune paroisse trouvée !",
                                      )),
                          ],
                        ),
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
