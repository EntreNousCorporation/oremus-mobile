import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_detail_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestHistoryDetailScreen extends StatelessWidget {
  const MassRequestHistoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<MassRequestHistoryDetailController>(builder: (_) {
        return KeyboardDismisser(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: AppConstants.kExpandedHeight,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorGreen,
                    elevation: 10,
                    shadowColor: colorGrey2.withOpacity(0.8),
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                    ),
                    actions: [
                      LikeButton(
                        isLiked: _.paroisseSelected.value.isFavorite,
                        onTap: (isLiked) async {
                          log('isLiked => $isLiked');
                          _.paroisseSelected.value.isFavorite = !isLiked;
                          if (isLiked) {
                            _.removeFavorite(_.paroisseSelected.value, isLiked);
                          } else {
                            _.saveFavorite(_.paroisseSelected.value, isLiked);
                          }
                          return !isLiked;
                        },
                        size: 25,
                        circleColor: const CircleColor(
                            start: Color(0xff93291E), end: Color(0xFFED213A)),
                        bubblesColor: const BubblesColor(
                          dotPrimaryColor: Color(0xFFED213A),
                          dotSecondaryColor: Color(0xff93291E),
                        ),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color:
                                isLiked ? const Color(0xFFED213A) : colorWhite,
                            size: 25,
                          );
                        },
                      ),
                      Separators.minimunHorizontal(),
                      IconButton(
                        onPressed: () {
                          _.goToMap();
                        },
                        icon: const Icon(Icons.map_rounded),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _.paroisseSelected.value.name ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorWhite),
                          ),
                        ),
                        background: (_.paroisseSelected.value.coverImage?.link
                                    ?.isNotEmpty ==
                                true)
                            ? Stack(
                                children: [
                                  CachedNetworkImage(
                                    width: Get.width,
                                    height: Get.width,
                                    imageUrl: _.paroisseSelected.value
                                            .coverImage?.link ??
                                        '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        LottieLoadingView(size: Get.width / 6),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  Container(
                                    height: Get.width,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Image.asset(
                                    Assets.imagesBgLogin,
                                    width: Get.width,
                                    height: Get.width,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    height: Get.width,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              )),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          //Separators.minimunVertical(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: getColor(_.massRequestSelected.value.status?.code),)),
                            child: Icon(
                              getIcon(_.massRequestSelected.value.status?.code),
                              color: getColor(_.massRequestSelected.value.status?.code),
                              size: Get.width / 10,
                            ),
                          ),
                          Separators.customSizeVertical(10),
                          Text(
                            _.massRequestSelected.value.status?.name?.fr ?? '-',
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: getColor(_.massRequestSelected.value.status?.code),
                            ),
                          ),
                          Separators.normalVertical(),
                          SizedBox(
                            width: double.maxFinite,
                            child: Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      'Type de demande',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      _.massRequestSelected.value
                                              .typeOfMassRequest?.name?.fr ??
                                          '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Période',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      '${getCustomDate(_.massRequestSelected.value.startDate ?? '')} au ${getCustomDate(_.massRequestSelected.value.endDate ?? '')}',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Montant',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      '${_.massRequestSelected.value.price.toString().split('.').first.amountFormat()} FCFA',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Intention de prière',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      _.massRequestSelected.value
                                              .prayerIntent ??
                                          '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.maximum1Vertical(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Visibility(
                                          visible: _.massRequestSelected.value
                                                  .status?.code?.isEmpty ==
                                              false,
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  _.moveToMassRequestClaims(_
                                                      .massRequestSelected
                                                      .value);
                                                },
                                                child: Container(
                                                  color: colorTransparent,
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .real_estate_agent_rounded,
                                                        color: colorTurquois,
                                                        size: Get.width / 10,
                                                      ),
                                                      Separators
                                                          .customSizeVertical(
                                                              3),
                                                      Text(
                                                        'Faire une \nréclamation',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyles
                                                            .montserratMedium(
                                                          textSize:
                                                              TextSizes.fifteen,
                                                          textColor:
                                                              colorTurquois,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Separators.maximumHorizontal(),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _.moveToMassRequest(
                                                _.massRequestSelected.value);
                                          },
                                          child: Container(
                                            color: colorTransparent,
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.history_rounded,
                                                  color: colorTurquois,
                                                  size: Get.width / 10,
                                                ),
                                                Separators.customSizeVertical(
                                                    3),
                                                Text(
                                                  'Répéter\n',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyles
                                                      .montserratMedium(
                                                    textSize: TextSizes.fifteen,
                                                    textColor: colorTurquois,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
      }),
    );
  }
}
