import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/diocese/controller/diocese_controller.dart';
import 'package:oremusapp/app/modules/diocese/views/widget/gridview_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DioceseScreen extends StatelessWidget {
  const DioceseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<DioceseController>(
            initState: (state) {},
            builder: (_) {
              return WillPopScope(
                onWillPop: () async => _.unlockBackButton.value,
                child: KeyboardDismisser(
                  child: SmartRefresher(
                    controller: _.refreshController,
                    onRefresh: _.onRefresh,
                    header: const CustomClassicHeader(),
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
                                  GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      elevation: 10,
                                      color: colorWhite,
                                      shadowColor: colorGrey2.withOpacity(0.5),
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
                                  Separators.normalHorizontal(),
                                  Expanded(
                                    child: Hero(
                                      tag: 'search',
                                      child: SizedBox(
                                        height: (Get.width / 9),
                                        child: const SearchWidget(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Separators.maximumVertical(),
                            _.isDataProcessing.isTrue
                                ? Expanded(
                                    child: Center(
                                      child: LottieLoadingView(
                                        size: 25,
                                      ),
                                    ),
                                  )
                                : _.hasData.isTrue
                                    ? Expanded(
                                        child: FadeIn(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 0,
                                              bottom: 0,
                                              left: 16,
                                              right: 16,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: GridView.builder(
                                                    //physics: const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                      //childAspectRatio: 3 / 2,
                                                      crossAxisCount: 2,
                                                      crossAxisSpacing: 0.0,
                                                      mainAxisSpacing: 16.0,
                                                    ),
                                                    itemCount:
                                                        _.dioceses.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var paroisse =
                                                          _.dioceses[index];
                                                      return GridviewItem(
                                                          diocese: paroisse);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: NotFoundScreen(
                                        message: "Aucun diocèse trouvé !",
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
