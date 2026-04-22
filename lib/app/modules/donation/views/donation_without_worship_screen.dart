import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/image_displayer.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_without_worship_controller.dart';
import 'package:oremusapp/app/modules/donation/views/widget/amount_without_worship_widget.dart';
import 'package:oremusapp/app/modules/donation/views/widget/donation_description_without_worship_widget.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationWithoutWorshipScreen extends StatelessWidget {
  const DonationWithoutWorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGrey5,
      child: GetBuilder<DonationWithoutWorshipController>(builder: (controller) {
        return KeyboardDismisser(
          child: PopScope(
            canPop: controller.unlockBackButton.value,
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
                      // Back button with improved styling
                      leading: Container(
                        margin: const EdgeInsets.only(left: 12, top: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Faire un don',
                            maxLines: 1,
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
                                // Cover image with fade animation
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: 1.0,
                                  child: (controller.selectedEntityType.value ==
                                      EntityType.worship.name &&
                                      controller.paroisseSelected.value.coverImage?.link
                                          ?.isNotEmpty == true)
                                      ? CachedNetworkImage(
                                    imageUrl: controller.paroisseSelected.value
                                        .coverImage?.link ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        LottieLoadingView(size: Get.width / 6),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          Assets.imagesBgLogin,
                                          fit: BoxFit.cover,
                                        ),
                                  )
                                      : Image.asset(
                                    Assets.imagesBgLogin,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Enhanced gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                      stops: const [0.4, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Form content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and introduction section - Redesigned
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30, bottom: 24),
                              child: Row(
                                children: [
                                  // Animated container for icon
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 700),
                                    builder: (context, double value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorGreenSemiLight
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                                15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorGreenSemiLight
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const ImageDisplayer(
                                            icon: Assets.imagesVolunteer,
                                            height: 20,
                                            color: colorGreenSemiLight,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          'Faire un don',
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

                            // Beneficiary selection section - Enhanced with animation
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(0, (1 - value) * 20),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 24),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                                alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: colorGreenSemiLight
                                                      .withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius
                                                      .circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.person_outline_rounded,
                                                  color: colorGreenSemiLight,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'À qui souhaitez-vous faire un don ?',
                                                  style: TextStyles
                                                      .montserratSemiBold(
                                                    textColor: colorGreenSemiLight,
                                                    textSize: TextSizes.sixteen,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          // OREMUS and PAROISSE options - Enhanced with modern styling
                                          Row(
                                            children: [
                                              // OREMUS option
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controller.selectEntityType(EntityType.oremus.name);
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    decoration: BoxDecoration(
                                                      color: controller
                                                          .selectedEntityType
                                                          .value ==
                                                          EntityType.oremus.name
                                                          ? colorGreenSemiLight
                                                          .withValues(
                                                          alpha: 0.12)
                                                          : colorGrey5,
                                                      borderRadius: BorderRadius
                                                          .circular(16),
                                                      border: Border.all(
                                                        color: controller
                                                            .selectedEntityType
                                                            .value ==
                                                            EntityType.oremus
                                                                .name
                                                            ? colorGreenSemiLight
                                                            : Colors.grey[300]!,
                                                        width:
                                                        controller.selectedEntityType
                                                            .value ==
                                                            EntityType.oremus
                                                                .name ? 2 : 1,
                                                      ),
                                                      boxShadow: controller
                                                          .selectedEntityType
                                                          .value ==
                                                          EntityType.oremus.name
                                                          ? [
                                                        BoxShadow(
                                                          color: colorGreenSemiLight
                                                              .withValues(
                                                              alpha: 0.2),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ]
                                                          : [],
                                                    ),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment: Alignment
                                                          .center,
                                                      children: [
                                                        Column(
                                                          mainAxisSize: MainAxisSize
                                                              .min,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets
                                                                  .all(12),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .oremus
                                                                        .name
                                                                    ? colorGreenSemiLight
                                                                    : Colors
                                                                    .grey[300],
                                                                boxShadow: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .oremus
                                                                        .name
                                                                    ? [
                                                                  BoxShadow(
                                                                    color: colorGreenSemiLight
                                                                        .withValues(
                                                                        alpha: 0.3),
                                                                    blurRadius: 8,
                                                                    offset: const Offset(
                                                                        0, 3),
                                                                  ),
                                                                ]
                                                                    : [],
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .home_work_outlined,
                                                                color: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .oremus
                                                                        .name
                                                                    ? colorWhite
                                                                    : Colors
                                                                    .grey[700],
                                                                size: 24,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 12),
                                                            Text(
                                                              'OREMUS',
                                                              style: TextStyles
                                                                  .montserratBold(
                                                                textColor: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .oremus
                                                                        .name
                                                                    ? colorGreenSemiLight
                                                                    : Colors
                                                                    .grey[700]!,
                                                                textSize: TextSizes
                                                                    .fifteen,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (controller.selectedEntityType
                                                            .value ==
                                                            EntityType.oremus
                                                                .name)
                                                          const Positioned(
                                                            top: -12,
                                                            right: 10,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(top: 8),
                                                              child: Icon(
                                                                Icons
                                                                    .check_circle_rounded,
                                                                color: colorGreenSemiLight,
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),

                                              // PAROISSE option
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controller.selectEntityType(
                                                        EntityType.worship
                                                            .name);
                                                  },
                                                  child: AnimatedContainer(
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 20),
                                                    decoration: BoxDecoration(
                                                      color: controller
                                                          .selectedEntityType
                                                          .value ==
                                                          EntityType.worship
                                                              .name
                                                          ? colorGreenSemiLight
                                                          .withValues(
                                                          alpha: 0.12)
                                                          : colorGrey5,
                                                      borderRadius: BorderRadius
                                                          .circular(16),
                                                      border: Border.all(
                                                        color: controller
                                                            .selectedEntityType
                                                            .value ==
                                                            EntityType.worship
                                                                .name
                                                            ? colorGreenSemiLight
                                                            : Colors.grey[300]!,
                                                        width: controller
                                                            .selectedEntityType
                                                            .value ==
                                                            EntityType.worship
                                                                .name
                                                            ? 2
                                                            : 1,
                                                      ),
                                                      boxShadow: controller
                                                          .selectedEntityType
                                                          .value ==
                                                          EntityType.worship
                                                              .name
                                                          ? [
                                                        BoxShadow(
                                                          color: colorGreenSemiLight
                                                              .withValues(
                                                              alpha: 0.2),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ]
                                                          : [],
                                                    ),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment: Alignment
                                                          .center,
                                                      children: [
                                                        Column(
                                                          mainAxisSize: MainAxisSize
                                                              .min,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets
                                                                  .all(12),
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .worship
                                                                        .name
                                                                    ? colorGreenSemiLight
                                                                    : Colors
                                                                    .grey[300],
                                                                boxShadow: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .worship
                                                                        .name
                                                                    ? [
                                                                  BoxShadow(
                                                                    color: colorGreenSemiLight
                                                                        .withValues(
                                                                        alpha: 0.3),
                                                                    blurRadius: 8,
                                                                    offset: const Offset(
                                                                        0, 3),
                                                                  ),
                                                                ]
                                                                    : [],
                                                              ),
                                                              child: Icon(
                                                                Icons
                                                                    .church_outlined,
                                                                color: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .worship
                                                                        .name
                                                                    ? colorWhite
                                                                    : Colors
                                                                    .grey[700],
                                                                size: 24,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 12),
                                                            Text(
                                                              'PAROISSE',
                                                              style: TextStyles
                                                                  .montserratBold(
                                                                textColor: controller
                                                                    .selectedEntityType
                                                                    .value ==
                                                                    EntityType
                                                                        .worship
                                                                        .name
                                                                    ? colorGreenSemiLight
                                                                    : Colors
                                                                    .grey[700]!,
                                                                textSize: TextSizes
                                                                    .fifteen,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (controller.selectedEntityType
                                                            .value ==
                                                            EntityType.worship
                                                                .name)
                                                          const Positioned(
                                                            top: -12,
                                                            right: 10,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(top: 8),
                                                              child: Icon(
                                                                Icons
                                                                    .check_circle_rounded,
                                                                color: colorGreenSemiLight,
                                                                size: 24,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Parish selection section
                            if (controller.selectedEntityType.value ==
                                EntityType.worship.name)
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 400),
                                builder: (context, double value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, (1 - value) * 20),
                                    child: Opacity(
                                      opacity: value,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        margin: const EdgeInsets.only(
                                            bottom: 24),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                  alpha: 0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: colorGreenSemiLight
                                                        .withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius
                                                        .circular(12),
                                                  ),
                                                  child: const Icon(
                                                    Icons.place_outlined,
                                                    color: colorGreenSemiLight,
                                                    size: 22,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Choisir une paroisse',
                                                  style: TextStyles
                                                      .montserratSemiBold(
                                                    textColor: colorGreenSemiLight,
                                                    textSize: TextSizes.sixteen,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Obx(() {
                                              return GestureDetector(
                                                onTap: () {
                                                  controller.goToWorshipChoice();
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 20,
                                                      vertical: 16),
                                                  decoration: BoxDecoration(
                                                    color: colorGrey5,
                                                    borderRadius: BorderRadius
                                                        .circular(16),
                                                    border: Border.all(
                                                      color: controller.paroisseSelected
                                                          .value.identifier !=
                                                          null
                                                          ? colorGreenSemiLight
                                                          : Colors.grey[300]!,
                                                      width: controller.paroisseSelected
                                                          .value.identifier !=
                                                          null ? 2 : 1,
                                                    ),
                                                    boxShadow: controller
                                                        .paroisseSelected.value
                                                        .identifier != null
                                                        ? [
                                                      BoxShadow(
                                                        color: colorGreenSemiLight
                                                            .withValues(
                                                            alpha: 0.1),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                            0, 3),
                                                      ),
                                                    ]
                                                        : [],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: controller
                                                            .paroisseSelected
                                                            .value.identifier ==
                                                            null
                                                            ? Row(
                                                          children: [
                                                            Icon(
                                                              Icons.search,
                                                              size: 18,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'Sélectionner une paroisse',
                                                              style: TextStyles
                                                                  .montserratMedium(
                                                                textColor: Colors
                                                                    .grey[600]!,
                                                                textSize: TextSizes
                                                                    .fifteen,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                            : Text(
                                                          '${controller.paroisseSelected
                                                              .value.name}',
                                                          style: TextStyles
                                                              .montserratSemiBold(
                                                            textColor: colorBlack,
                                                            textSize: TextSizes
                                                                .fifteen,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 36,
                                                        height: 36,
                                                        decoration: BoxDecoration(
                                                          color: colorGreenSemiLight
                                                              .withValues(
                                                              alpha: 0.1),
                                                          shape: BoxShape
                                                              .circle,
                                                        ),
                                                        child: Icon(
                                                          controller.paroisseSelected
                                                              .value
                                                              .identifier !=
                                                              null
                                                              ? Icons
                                                              .edit_rounded
                                                              : Icons
                                                              .arrow_forward_ios_rounded,
                                                          size: 18,
                                                          color: colorGreenSemiLight,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // Amount section - Redesigned
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(0, (1 - value) * 20),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 24),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                                alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: colorGreenSemiLight
                                                      .withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius
                                                      .circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.payments_rounded,
                                                  color: colorGreenSemiLight,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Montant (FCFA)',
                                                style: TextStyles
                                                    .montserratSemiBold(
                                                  textColor: colorGreenSemiLight,
                                                  textSize: TextSizes.sixteen,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // Amount input widget
                                          const AmountWithoutWorshipWidget(),
                                          const SizedBox(height: 16),

                                          // Minimum amount information
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: colorGreenSemiLight
                                                  .withValues(alpha: 0.08),
                                              borderRadius: BorderRadius
                                                  .circular(12),
                                              border: Border.all(
                                                color: colorGreenSemiLight
                                                    .withValues(alpha: 0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.info_outline_rounded,
                                                  size: 20,
                                                  color: colorGreenSemiLight,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    'Le montant minimum est de 100 FCFA',
                                                    style: TextStyles
                                                        .montserratMedium(
                                                      textColor: colorGreenSemiLight,
                                                      textSize: TextSizes
                                                          .fourteen,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Quick amount buttons
                                          const SizedBox(height: 16),
                                          Text(
                                            'Montants suggérés',
                                            style: TextStyles.montserratMedium(
                                              textColor: Colors.grey[700]!,
                                              textSize: TextSizes.fourteen,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              _buildQuickAmountButton(
                                                  controller, '1 000', '1 000'),
                                              const SizedBox(width: 8),
                                              _buildQuickAmountButton(
                                                  controller, '5 000', '5 000'),
                                              const SizedBox(width: 8),
                                              _buildQuickAmountButton(
                                                  controller, '10 000', '10 000'),
                                              const SizedBox(width: 8),
                                              _buildQuickAmountButton(
                                                  controller, '20 000', '20 000'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Description section
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              builder: (context, double value, child) {
                                return Transform.translate(
                                  offset: Offset(0, (1 - value) * 20),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 30),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                                alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: colorGreenSemiLight
                                                      .withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius
                                                      .circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.description_outlined,
                                                  color: colorGreenSemiLight,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Description',
                                                style: TextStyles
                                                    .montserratSemiBold(
                                                  textColor: colorGreenSemiLight,
                                                  textSize: TextSizes.sixteen,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),

                                          // Description textarea with improved style
                                          Container(
                                            decoration: BoxDecoration(
                                              color: colorGrey5,
                                              borderRadius: BorderRadius
                                                  .circular(16),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: const DonationDescriptionWithoutWorshipWidget(),
                                          ),

                                          const SizedBox(height: 12),
                                          Text(
                                            'Décrivez l\'intention de votre don (optionnel)',
                                            style: TextStyles.montserratRegular(
                                              textColor: Colors.grey[600]!,
                                              textSize: TextSizes.thirteen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Confirmation button - Enhanced with animation
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: 0.8 + (value * 0.2),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 40),
                                      height: 60,
                                      child: CustomButton(
                                        text: 'Continuer',
                                        borderRadius: 16,
                                        textSize: TextSizes.seventeen,
                                        bgcolor: controller.isValidForm.isTrue
                                            ? colorGreen
                                            : colorGrey1.withValues(alpha: 0.5),
                                        borderColor: controller.isValidForm.isTrue
                                            ? colorGreen
                                            : colorGreen.withValues(alpha: 0),
                                        actionColor: colorGreen.withValues(alpha: 0.5),
                                        enabled: controller.isValidForm.value,
                                        action: () {
                                          controller.doSendDonation();
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
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
        );
      }),
    );
  }

  Widget _buildQuickAmountButton(DonationWithoutWorshipController controller, String displayAmount, String amount) {
    return Obx(() {
      // Utiliser selectedAmount pour vérifier la sélection
      bool isSelected = controller.selectedAmount.value == amount;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            // Mettre à jour directement le controller
            controller.amountController.text = amount;
            controller.selectedAmount.value = amount;
            controller.checkForm();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorGreenSemiLight.withValues(alpha: 0.1)
                  : colorGrey5,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? colorGreenSemiLight : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: colorGreenSemiLight.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ] : [],
            ),
            alignment: Alignment.center,
            child: Text(
              displayAmount,
              style: TextStyles.montserratSemiBold(
                textColor: isSelected ? colorGreenSemiLight : Colors.grey[600]!,
                textSize: TextSizes.fourteen,
              ),
            ),
          ),
        ),
      );
    });
  }
}