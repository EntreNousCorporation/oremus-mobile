import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_worship_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/filter_search_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FilterMassRequestWorshipScreen extends StatelessWidget {
  const FilterMassRequestWorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<FilterMassRequestWorshipController>(builder: (_) {
          return WillPopScope(
            onWillPop: () async => false,
            child: KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: Container(
                  color: colorGrey4,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  //_.doResetAndCloseFilter();
                                  _.goBackToMassRequest();
                                },
                                icon: const Icon(
                                  Icons.cancel_rounded,
                                  size: 30,
                                ),
                              ),
                              Text(
                                _.title.value,
                                style: TextStyles.montserratBold(
                                  textColor: colorBlack,
                                  textSize: TextSizes.twenty,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Separators.normalVertical(),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: Text(
                            'Choisir une paroisse',
                            style: TextStyles.montserratBold(
                              textColor: colorBlack,
                              textSize: TextSizes.thirty_eight,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: colorGrey4,
                            width: double.infinity,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _.doLaunchSimpleSearch();
                                        },
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          elevation: 10,
                                          color: colorWhite,
                                          shadowColor:
                                              colorGrey2.withValues(alpha: 0.5),
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
                                          child: const FilterSearchWidget(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Separators.minimunVertical(),
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
                                              child: NotificationListener<
                                                  OverscrollIndicatorNotification>(
                                                onNotification: (notification) {
                                                  notification
                                                      .disallowIndicator();
                                                  return false;
                                                },
                                                child: SmartRefresher(
                                                  enablePullDown: true,
                                                  enablePullUp: true,
                                                  onRefresh: _.onRefresh,
                                                  onLoading: _.onLoading,
                                                  header:
                                                      const CustomClassicHeader(),
                                                  footer: CustomFooter(
                                                    builder:
                                                        (BuildContext context,
                                                            LoadStatus? mode) {
                                                      Widget body;
                                                      if (mode ==
                                                          LoadStatus.idle) {
                                                        body = Container();
                                                      } else if (mode ==
                                                          LoadStatus.loading) {
                                                        body =
                                                            LottieLoadingView();
                                                      } else if (mode ==
                                                          LoadStatus.failed) {
                                                        body = Text(
                                                          "Une erreur est survenue lors du chargement",
                                                          style: TextStyles
                                                              .montserratBold(
                                                                  textSize:
                                                                      TextSizes
                                                                          .thirteen,
                                                                  textColor:
                                                                      colorBlack),
                                                        );
                                                      } else if (mode ==
                                                          LoadStatus
                                                              .canLoading) {
                                                        body = Text(
                                                          "Relacher pour charger plus de paroisses",
                                                          style: TextStyles
                                                              .montserratBold(
                                                                  textSize:
                                                                      TextSizes
                                                                          .thirteen,
                                                                  textColor:
                                                                      colorBlack),
                                                        );
                                                      } else {
                                                        body = Visibility(
                                                          visible: false,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    Get.width /
                                                                        1.7,
                                                                height: 4,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
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
                                                                style: TextStyles.montserratBold(
                                                                    textSize:
                                                                        TextSizes
                                                                            .thirteen,
                                                                    textColor:
                                                                        colorBlack),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                      return SizedBox(
                                                        height: 55.0,
                                                        child:
                                                            Center(child: body),
                                                      );
                                                    },
                                                  ),
                                                  controller: _.refreshController,
                                                  physics: const BouncingScrollPhysics(),
                                                  child: ListView.separated(
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    padding: const EdgeInsets.only(
                                                      top: 16,
                                                      right: 16,
                                                      left: 16,
                                                    ),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        _.paroisses.length,
                                                    itemBuilder:
                                                        (builder, index) {
                                                      var paroisse =
                                                          _.paroisses[index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          _.worshipSelected
                                                              .value = paroisse;
                                                          _.goBackToMassRequest();
                                                        },
                                                        child: Material(
                                                          clipBehavior:
                                                              Clip.none,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          elevation: 10,
                                                          color: colorWhite,
                                                          shadowColor:
                                                              colorGrey2
                                                                  .withValues(alpha: 
                                                                      0.5),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                width: 80,
                                                                height: 80,
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              10.0)),
                                                                  child:
                                                                      SizedBox(
                                                                    //height: Get.width / 2.8,
                                                                    height:
                                                                        Get.width /
                                                                            2.2,
                                                                    width: double
                                                                        .infinity,
                                                                    child: (paroisse?.coverImage?.link?.isNotEmpty ==
                                                                            true)
                                                                        ? CachedNetworkImage(
                                                                            imageUrl:
                                                                                paroisse?.coverImage?.link ?? '',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            placeholder: (context, url) => SizedBox(
                                                                                width: Get.width / 4,
                                                                                height: Get.width / 4,
                                                                                child: LottieLoadingView(size: Get.width / 6)),
                                                                            errorWidget: (context, url, error) =>
                                                                                const Icon(Icons.error),
                                                                          )
                                                                        : Image
                                                                            .asset(
                                                                            'assets/images/bg_login.jpg',
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Separators
                                                                  .minimunHorizontal(),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${paroisse?.name}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style: TextStyles.montserratSemiBold(
                                                                          textSize: TextSizes
                                                                              .fifteen,
                                                                          textColor:
                                                                              colorBlack),
                                                                    ),
                                                                    Separators
                                                                        .customSizeVertical(
                                                                            3),
                                                                    Text(
                                                                      '${paroisse?.diocese?.name}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      softWrap:
                                                                          true,
                                                                      style: TextStyles.montserratRegular(
                                                                          textSize: TextSizes
                                                                              .thirteen,
                                                                          textColor:
                                                                              colorBlack),
                                                                    ),
                                                                    Separators
                                                                        .customSizeVertical(
                                                                            3),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          3.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(3),
                                                                        color:
                                                                            colorGreenSemiLight,
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        paroisse?.address?.municipality ??
                                                                            'N/A',
                                                                        style: TextStyles.montserratBold(
                                                                            textSize:
                                                                                TextSizes.eleven,
                                                                            textColor: colorWhite),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (builder, index) {
                                                      return Separators
                                                          .normal1Vertical();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : _.hasError.isTrue
                                            ? Expanded(
                                                child: NotFoundScreen(
                                                  message: _.errorMessage.value,
                                                ),
                                              )
                                            : Expanded(
                                                child: NotFoundScreen(
                                                  message:
                                                      "Aucune paroisse trouvée !",
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
              ),
            ),
          );
        }),
      ),
    );
  }
}
