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
import 'package:oremusapp/app/modules/massrequestclaim/controller/mass_request_claim_controller.dart';
import 'package:oremusapp/app/modules/massrequestclaim/views/widget/claim_type_filter.dart';
import 'package:oremusapp/app/modules/massrequestclaim/views/widget/claim_type_widget.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class MassRequestClaimScreen extends StatelessWidget {
  const MassRequestClaimScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: GetX<MassRequestClaimController>(builder: (controller) {
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
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
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
                          isLiked: controller.paroisseSelected.value.isFavorite,
                          onTap: (isLiked) async {
                            log('isLiked => $isLiked');
                            controller.paroisseSelected.value.isFavorite = !isLiked;
                            if (isLiked) {
                              controller.removeFavorite(controller.paroisseSelected.value, isLiked);
                            } else {
                              controller.saveFavorite(controller.paroisseSelected.value, isLiked);
                            }
                            return !isLiked;
                          },
                          size: 22,
                          circleColor: const CircleColor(
                              start: Color(0xff93291E),
                              end: Color(0xFFED213A)
                          ),
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
                            controller.goToMap();
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          controller.paroisseSelected.value.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratBold(
                            textSize: TextSizes.twenty,
                            textColor: colorWhite,
                          ),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
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
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Cover image with Hero animation
                              (controller.paroisseSelected.value.coverImage?.link?.isNotEmpty == true)
                                  ? Hero(
                                tag: 'tag${controller.paroisseSelected.value.identifier}',
                                child: CachedNetworkImage(
                                  width: Get.width,
                                  height: Get.width,
                                  imageUrl: controller.paroisseSelected.value.coverImage?.link ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => LottieLoadingView(size: Get.width / 6),
                                  errorWidget: (context, url, error) => Image.asset(
                                    Assets.imagesBgLogin,
                                    width: Get.width,
                                    height: Get.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                                  : Hero(
                                tag: 'tag${controller.paroisseSelected.value.identifier}',
                                child: Image.asset(
                                  Assets.imagesBgLogin,
                                  width: Get.width,
                                  height: Get.width,
                                  fit: BoxFit.cover,
                                ),
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

                  // Main content
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // Section header with icon
                          Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 24),
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
                                    Icons.assignment_outlined,
                                    color: colorGreenSemiLight,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Section title and subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Faire une réclamation',
                                        style: TextStyles.montserratBold(
                                          textSize: TextSizes.eighteen,
                                          textColor: colorGreenSemiLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Veuillez remplir le formulaire ci-dessous',
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

                          // Parish selector (hidden by default)
                          if (false) // requestMassWithoutWorship.value when feature available
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: colorGreenSemiLight.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.church_outlined,
                                            color: colorGreenSemiLight,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Paroisse',
                                          style: TextStyles.montserratSemiBold(
                                            textColor: colorGreenSemiLight,
                                            textSize: TextSizes.fifteen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      controller.goToWorshipChoice();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: controller.paroisseSelected.value.identifier != null
                                              ? colorGreenSemiLight
                                              : Colors.grey[300]!,
                                          width: controller.paroisseSelected.value.identifier != null ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: controller.paroisseSelected.value.identifier == null
                                                ? Text(
                                              'Choisir une paroisse',
                                              style: TextStyles.montserratMedium(
                                                textColor: Colors.grey[600]!,
                                                textSize: TextSizes.fifteen,
                                              ),
                                            )
                                                : Text(
                                              '${controller.paroisseSelected.value.name}',
                                              style: TextStyles.montserratSemiBold(
                                                textColor: colorBlack,
                                                textSize: TextSizes.fifteen,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: colorGreenSemiLight.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              controller.paroisseSelected.value.identifier != null
                                                  ? Icons.edit_rounded
                                                  : Icons.arrow_forward_ios_rounded,
                                              size: 16,
                                              color: colorGreenSemiLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),

                          // Claim type section
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.category_outlined,
                                          color: colorGreenSemiLight,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Type de réclamation',
                                        style: TextStyles.montserratSemiBold(
                                          textColor: colorGreenSemiLight,
                                          textSize: TextSizes.fifteen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                  child: const ClaimTypeFilter(),
                                ),
                              ],
                            ),
                          ),

                          // Description section
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: colorGreenSemiLight.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.description_outlined,
                                          color: colorGreenSemiLight,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Description',
                                        style: TextStyles.montserratSemiBold(
                                          textColor: colorGreenSemiLight,
                                          textSize: TextSizes.fifteen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                  child: const ClaimTypeWidget(),
                                ),
                              ],
                            ),
                          ),

                          // Submit button
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 30),
                            height: 56,
                            child: CustomButton(
                              text: 'Soumettre',
                              borderRadius: 16,
                              textSize: TextSizes.sixteen,
                              bgcolor: controller.isValidForm.isTrue
                                  ? colorGreenSemiLight
                                  : Colors.grey[300]!,
                              borderColor: controller.isValidForm.isTrue
                                  ? colorGreenSemiLight
                                  : Colors.grey[300]!,
                              textColor: controller.isValidForm.isTrue
                                  ? colorWhite
                                  : Colors.grey[500]!,
                              actionColor: colorGreenSemiLight.withValues(alpha: 0.8),
                              enabled: controller.isValidForm.value,
                              action: () {
                                controller.doSendClaim();
                              },
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
