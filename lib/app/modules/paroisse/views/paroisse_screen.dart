import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
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
                                    _.doLaunchSimpleSearch();
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
                                        Icons.search_rounded,
                                        color: colorPurpleLight,
                                      ),
                                    ),
                                  ),
                                ),
                                Separators.normalHorizontal(),
                                Expanded(
                                  child: SizedBox(
                                    height: (Get.width / 9),
                                    child: const SearchWidget(),
                                  ),
                                ),
                                Separators.normalHorizontal(),
                                GestureDetector(
                                  onTap: () {
                                    _.goToAdvancedSearch();
                                  },
                                  child: Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      elevation: 10,
                                      color: colorWhite,
                                      shadowColor: colorGrey2.withOpacity(0.5),
                                      child: Badge(
                                        showBadge: (_.searchCriteria.value
                                                    .isCriteriaEmpty ==
                                                false)
                                            ? true
                                            : false,
                                        badgeContent: Text(
                                          '${_.searchCriteria.value.countCriteria}',
                                          style: TextStyles.montserratRegular(
                                              textColor: colorWhite,
                                              textSize: TextSizes.thirteen),
                                        ),
                                        child: SizedBox(
                                          height: (Get.width / 9),
                                          width: (Get.width / 9),
                                          child: const Icon(
                                            Icons.filter_list_rounded,
                                            color: colorPurpleLight,
                                          ),
                                        ),
                                      )),
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
                                          child: SmartRefresher(
                                            //header: BezierCircleHeader(),
                                            enablePullDown: true,
                                            enablePullUp: true,
                                            onRefresh: _.onRefresh,
                                            onLoading: _.onLoading,
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
                                                    style: TextStyles
                                                        .montserratBold(
                                                            textSize: TextSizes
                                                                .thirteen,
                                                            textColor:
                                                                colorBlack),
                                                  );
                                                } else if (mode ==
                                                    LoadStatus.canLoading) {
                                                  body = Text(
                                                    "Charger plus de paroisses",
                                                    style: TextStyles
                                                        .montserratBold(
                                                            textSize: TextSizes
                                                                .thirteen,
                                                            textColor:
                                                                colorBlack),
                                                  );
                                                } else {
                                                  body = Column(
                                                    children: [
                                                      SizedBox(
                                                        width: Get.width / 1.7,
                                                        height: 4,
                                                        child: Container(
                                                          decoration:
                                                          BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
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
                                                      Separators
                                                          .minimunVertical(),
                                                      Text(
                                                        "Aucune donnée à charger",
                                                        style: TextStyles
                                                            .montserratBold(
                                                                textSize:
                                                                    TextSizes
                                                                        .thirteen,
                                                                textColor:
                                                                    colorBlack),
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
                                            physics:
                                                const BouncingScrollPhysics(),
                                            controller: _.refreshController,
                                            child: ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: false,
                                                itemCount: _.paroisses.length,
                                                itemBuilder: (builder, index) {
                                                  var paroisse =
                                                      _.paroisses[index];
                                                  return ParoisseItem(
                                                    paroisse: paroisse,
                                                    index: index,
                                                  );
                                                }),
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
              );
            }),
      ),
    );
  }
}
