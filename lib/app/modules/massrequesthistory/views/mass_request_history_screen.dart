import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/history_item.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/search_widget.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class MassRequestHistoryScreen extends StatelessWidget {
  const MassRequestHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: GetX<MassRequestHistoryController>(builder: (_) {
        return KeyboardDismisser(
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            resizeToAvoidBottomInset: true,
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Enhanced header with cover image
                  SliverAppBar(
                    expandedHeight: AppConstants.kExpandedHeight,
                    collapsedHeight: 100,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorGreen,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    // Back button
                    leading: Container(
                      margin: const EdgeInsets.only(left: 8, top: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: colorWhite,
                          size: 22,
                        ),
                      ),
                    ),
                    // Actions (favorites, map)
                    actions: requestMassWithoutWorship.value ? null : [
                      // Favorites button
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LikeButton(
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
                              color: isLiked ? const Color(0xFFED213A) : colorWhite,
                              size: 22,
                            );
                          },
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Map button
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            _.goToMap();
                          },
                          icon: const Icon(
                            Icons.map_rounded,
                            color: colorWhite,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                    // Title and background image
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _.paroisseSelected.value.name ?? 'Mes demandes de messes',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.eighteen,
                            textColor: colorWhite,
                          ),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Cover image
                              (_.paroisseSelected.value.coverImage?.link?.isNotEmpty == true)
                                  ? CachedNetworkImage(
                                imageUrl: _.paroisseSelected.value.coverImage?.link ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    LottieLoadingView(size: Get.width / 6),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      Assets.imagesBgLogin,
                                      width: Get.width,
                                      height: Get.width,
                                      fit: BoxFit.cover,
                                    ),
                              )
                                  : Image.asset(
                                Assets.imagesBgLogin,
                                width: Get.width,
                                height: Get.width,
                                fit: BoxFit.cover,
                              ),
                              // Shadow overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                    stops: const [0.5, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Search section and mass requests list
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorGreenSemiLight.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorGreenSemiLight.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.church_outlined,
                                  color: colorGreenSemiLight,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Section title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Historique de demandes',
                                      style: TextStyles.montserratBold(
                                        textSize: TextSizes.eighteen,
                                        textColor: colorGreenSemiLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Vos demandes de messes',
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: Colors.grey[600]!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced search bar with filters
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Search icon container
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    color: colorGreenSemiLight,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),

                                // Search field
                                const Expanded(
                                  child: SizedBox(
                                    height: 56,
                                    child: Center(
                                      child: SearchWidget(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Mass requests list or loading/empty indicators
                        _.isDataProcessing.isTrue
                            ? SizedBox(
                          height: 200,
                          child: Center(
                            child: LottieLoadingView(
                              size: Get.width / 4,
                            ),
                          ),
                        )
                            : _.hasData.isTrue
                            ? FadeIn(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // List of mass requests
                                ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var massRequest = _.massRequests[index];
                                    return HistoryItem(massRequest: massRequest);
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 16);
                                  },
                                  itemCount: _.massRequests.length,
                                ),

                                const SizedBox(height: 30),

                                // Button for new request with enhanced design
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      _.doNewMassRequest();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                      decoration: BoxDecoration(
                                        color: colorGreenSemiLight,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorGreenSemiLight.withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Nouvelle demande de messe',
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.fifteen,
                                              textColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        )
                            : SizedBox(
                          height: 380,
                          child: Column(
                            children: [
                              Expanded(
                                child: NotFoundScreen(
                                  message: "Aucune demande de messe trouvée !",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                child: GestureDetector(
                                  onTap: () {
                                    _.doNewMassRequest();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    decoration: BoxDecoration(
                                      color: colorGreenSemiLight,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorGreenSemiLight.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 14),
                                          Text(
                                            'Créer votre première demande',
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.sixteen,
                                              textColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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