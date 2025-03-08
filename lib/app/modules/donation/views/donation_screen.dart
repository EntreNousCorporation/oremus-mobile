import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_controller.dart';
import 'package:oremusapp/app/modules/donation/views/widget/amount_widget.dart';
import 'package:oremusapp/app/modules/donation/views/widget/donation_description_widget.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<DonationController>(builder: (_) {
      return KeyboardDismisser(
        child: PopScope(
          canPop: _.unlockBackButton.value,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: colorWhite,
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
                    collapsedHeight: 100,
                    floating: false,
                    snap: false,
                    pinned: true,
                    backgroundColor: colorGreen,
                    elevation: 10,
                    shadowColor: colorGrey2.withValues(alpha: 0.8),
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                        //Get.delete<FilterDonationDateController>(force: true);
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: colorWhite,),
                    ),
                    actions: [
                      Visibility(
                        visible: false,
                        child: IconButton(
                          onPressed: () {
                            _.moveToHome();
                          },
                          icon: const Icon(Icons.home_filled),
                        ),
                      ),
                      Separators.minimunHorizontal(),
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
                        icon: const Icon(Icons.map_rounded, color: colorWhite,),
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
                            textColor: colorWhite,
                          ),
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
                              color: Colors.black54.withValues(alpha: 0.3),
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
                              color: Colors.black54.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Separators.minimunVertical(),
                          Text(
                            'Faire un don',
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          Separators.normalVertical(),
                          Separators.maximum1Vertical(),

                          Text(
                            'Montant (FCFA)',
                            style: TextStyles.montserratMedium(
                              textColor: colorGrey1,
                              textSize: TextSizes.fourteen,
                            ),
                          ),
                          Separators.customSizeVertical(8),
                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 10,
                            color: colorWhite,
                            shadowColor: colorGrey2.withValues(alpha: 0.5),
                            child: const AmountWidget(),
                          ),
                          Separators.minimunVertical(),
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 20, color: colorGreen),
                              Separators.customSizeHorizontal(4),
                              Text(
                                'Le montant minimum est de 100 FCFA',
                                style: TextStyles.montserratRegular(
                                  textColor: colorGrey1,
                                  textSize: TextSizes.fourteen,
                                ),
                              ),
                            ],
                          ),
                          Separators.maximumVertical(),

                          Text(
                            'Description',
                            style: TextStyles.montserratMedium(
                              textColor: colorGrey1,
                              textSize: TextSizes.fourteen,
                            ),
                          ),
                          Separators.customSizeVertical(8),
                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 10,
                            color: colorWhite,
                            shadowColor: colorGrey2.withValues(alpha: 0.5),
                            child: const DonationDescriptionWidget(),
                          ),
                          Separators.maximum1Vertical(),
                          Separators.normalVertical(),

                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 10,
                            color: colorWhite,
                            shadowColor: colorGrey2.withValues(alpha: 0.5),
                            child: CustomButton(
                              text: 'Continuer',
                              borderRadius: 10,
                              textSize: TextSizes.sixteen,
                              bgcolor: _.isValidForm.isTrue
                                  ? colorGreen
                                  : colorGrey1.withValues(alpha: 0.5),
                              borderColor: _.isValidForm.isTrue
                                  ? colorGreen
                                  : colorGreen.withValues(alpha: 0),
                              actionColor: colorGreen.withValues(alpha: 0.5),
                              enabled: _.isValidForm.value,
                              action: () {
                                _.doSendDonation();
                              },
                            ),
                          ),
                          Separators.maximum1Vertical(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
