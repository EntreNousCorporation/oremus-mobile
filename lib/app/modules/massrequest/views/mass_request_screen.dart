import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/intent_type_description_widget.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_hour_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_repetition_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_type_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/shimmer_price.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestScreen extends StatelessWidget {
  const MassRequestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<MassRequestController>(builder: (_) {
        return KeyboardDismisser(
          child: WillPopScope(
            onWillPop: () async => _.unlockBackButton.value,
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
                      collapsedHeight: 100,
                      floating: false,
                      snap: false,
                      pinned: true,
                      backgroundColor: colorGreen,
                      elevation: 10,
                      shadowColor: colorGrey2.withOpacity(0.8),
                      leading: IconButton(
                        onPressed: () {
                          Get.back();
                          Get.delete<FilterMassRequestDateController>(force: true);
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded),
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
                              'Faire une demande de messe',
                              textAlign: TextAlign.center,
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                            Separators.normalVertical(),
                            Separators.maximum1Vertical(),
                            Text(
                              'Type de demande de messe',
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
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: const MassTypeFilter(),
                            ),
                            Separators.maximumVertical(),

                            //WORSHIP HOURS
                            Text(
                              'Date',
                              style: TextStyles.montserratMedium(
                                textColor: colorGrey1,
                                textSize: TextSizes.fourteen,
                              ),
                            ),
                            Separators.customSizeVertical(8),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          _.showPicker(context);
                                        },
                                        child: Material(
                                          borderRadius: BorderRadius.circular(10.0),
                                          elevation: 10,
                                          color: colorWhite,
                                          shadowColor: colorGrey2.withOpacity(0.5),
                                          child: _.isDatesProcessing.isTrue ? const ShimmerPrice(height: 50) : Container(
                                            padding: const EdgeInsets.all(12),
                                            width: double.maxFinite,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '${_.selectedDate.value?.dayToDisplay}',
                                                  style: TextStyles.montserratBold(
                                                    textColor: colorBlack,
                                                    textSize: TextSizes.sixteen,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.arrow_drop_down_rounded,
                                                  size: 25,
                                                  color: colorGreen,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Separators.customSizeHorizontal(16),
                                    Expanded(
                                      child: Material(
                                        borderRadius: BorderRadius.circular(10.0),
                                        elevation: 10,
                                        color: colorWhite,
                                        shadowColor: colorGrey2.withOpacity(0.5),
                                        child: const MassTypeHourFilter(),
                                      ),
                                    ),
                                  ],
                                ),
                                Separators.maximumVertical(),
                              ],
                            ),

                            //NUMBER OF MASS
                            Text(
                              'Répétition',
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
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: const MassTypeRepetitionFilter(),
                            ),
                            Separators.maximumVertical(),
                            Visibility(
                              visible: _.massRequestTypeRepetitionSelected.value?.code == 'many',
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _.goToDatesChoice();
                                    },
                                    child: Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      elevation: 10,
                                      color: colorWhite,
                                      shadowColor: colorGrey2.withOpacity(0.5),
                                      child: _.isDatesProcessing.isTrue ? const ShimmerPrice(height: 50) : Container(
                                        padding: const EdgeInsets.all(12),
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              'Choisir les horaires de messe',
                                              style: TextStyles.montserratMedium(
                                                textColor: colorGrey1,
                                                textSize: TextSizes.fourteen,
                                              ),
                                            ),
                                            Icon(
                                              (_.datesChoosen.length > 1 && _.massRequestTypeRepetitionSelected.value?.code == 'many') ? Icons.check_circle : Icons.arrow_drop_down_rounded,
                                              size: 25,
                                              color: _.worshipHours.isNotEmpty ? colorGreen : colorGrey1.withOpacity(0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Separators.maximumVertical(),
                                ],
                              ),
                            ),

                            Text(
                              'Intention de messe',
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
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: const IntentTypeDescriptionWidget(),
                            ),
                            Separators.maximumVertical(),

                            //PRICING
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: _.isPricingProcessing.isTrue ? const ShimmerPrice(height: 70) :  Container(
                                padding: const EdgeInsets.all(24),
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  color: colorGreenlight2,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Tarif:',
                                      style: TextStyles.montserratBold(
                                        textColor: colorGreySeparator,
                                        textSize: TextSizes.twenty,
                                      ),
                                    ),
                                    Separators.normalHorizontal(),
                                    Text(
                                      _.getPrice().value,
                                      style: TextStyles.montserratBold(
                                        textColor: colorBlack,
                                        textSize: TextSizes.twenty_four,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Separators.maximum1Vertical(),

                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: CustomButton(
                                text: 'Continuer',
                                borderRadius: 10,
                                textSize: TextSizes.sixteen,
                                bgcolor: _.isValidForm.isTrue
                                    ? colorGreen
                                    : colorGrey1.withOpacity(0.5),
                                borderColor: _.isValidForm.isTrue
                                    ? colorGreen
                                    : colorGreen.withOpacity(0),
                                actionColor: colorGreen.withOpacity(0.5),
                                enabled: _.isValidForm.value,
                                action: () {
                                  _.doSendMassRequest();
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
      }),
    );
  }
}
