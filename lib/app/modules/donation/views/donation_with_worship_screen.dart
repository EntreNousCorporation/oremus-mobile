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
import 'package:oremusapp/app/modules/donation/controller/donation_with_worship_controller.dart';
import 'package:oremusapp/app/modules/donation/views/widget/amount_without_worship_widget.dart';
import 'package:oremusapp/app/modules/donation/views/widget/donation_description_with_worship_widget.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationWithWorshipScreen extends StatelessWidget {
  const DonationWithWorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: GetX<DonationWithWorshipController>(builder: (_) {
        return KeyboardDismisser(
          child: PopScope(
            canPop: _.unlockBackButton.value,
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
                    // Header with background image
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
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0),
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
                                (_.selectedEntityType.value ==
                                            EntityType.worship.name &&
                                        _.paroisseSelected.value.coverImage
                                                ?.link?.isNotEmpty ==
                                            true)
                                    ? CachedNetworkImage(
                                        imageUrl: _.paroisseSelected.value
                                                .coverImage?.link ??
                                            '',
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            LottieLoadingView(
                                                size: Get.width / 6),
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

                    // Form content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and introduction section
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 30, bottom: 24),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          colorGreenSemiLight.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorGreenSemiLight.withValues(alpha: 0.1),
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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

                            // Beneficiary selection section
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colorGreenSemiLight
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                          style: TextStyles.montserratSemiBold(
                                            textColor: colorGreenSemiLight,
                                            textSize: TextSizes.sixteen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // OREMUS and PAROISSE options
                                  Row(
                                    children: [
                                      // OREMUS option
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _.selectEntityType(
                                                EntityType.oremus.name);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            decoration: BoxDecoration(
                                              color:
                                                  _.selectedEntityType.value ==
                                                          EntityType.oremus.name
                                                      ? colorGreenSemiLight
                                                          .withValues(alpha: 0.12)
                                                      : Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: _.selectedEntityType
                                                            .value ==
                                                        EntityType.oremus.name
                                                    ? colorGreenSemiLight
                                                    : Colors.grey[300]!,
                                                width: _.selectedEntityType
                                                            .value ==
                                                        EntityType.oremus.name
                                                    ? 2
                                                    : 1,
                                              ),
                                              boxShadow: _.selectedEntityType
                                                          .value ==
                                                      EntityType.oremus.name
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            colorGreenSemiLight
                                                                .withValues(alpha: 
                                                                    0.2),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                      const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: _.selectedEntityType
                                                            .value ==
                                                            EntityType
                                                                .oremus.name
                                                            ? colorGreenSemiLight
                                                            : Colors.grey[300],
                                                        boxShadow:
                                                        _.selectedEntityType
                                                            .value ==
                                                            EntityType
                                                                .oremus.name
                                                            ? [
                                                          BoxShadow(
                                                            color: colorGreenSemiLight
                                                                .withValues(alpha: 
                                                                0.3),
                                                            blurRadius: 8,
                                                            offset:
                                                            const Offset(
                                                                0, 3),
                                                          ),
                                                        ]
                                                            : [],
                                                      ),
                                                      child: Icon(
                                                        Icons.home_work_outlined,
                                                        color: _.selectedEntityType
                                                            .value ==
                                                            EntityType
                                                                .oremus.name
                                                            ? colorWhite
                                                            : Colors.grey[700],
                                                        size: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      'OREMUS',
                                                      style:
                                                      TextStyles.montserratBold(
                                                        textColor:
                                                        _.selectedEntityType
                                                            .value ==
                                                            EntityType
                                                                .oremus.name
                                                            ? colorGreenSemiLight
                                                            : Colors.grey[700]!,
                                                        textSize: TextSizes.fifteen,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (_.selectedEntityType
                                                    .value ==
                                                    EntityType.oremus.name)
                                                  const Positioned(
                                                    top: -20,
                                                    right: 10,
                                                    child: Padding(
                                                      padding:
                                                      EdgeInsets.only(top: 8),
                                                      child: Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color:
                                                        colorGreenSemiLight,
                                                        size: 20,
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
                                            _.selectEntityType(
                                                EntityType.worship.name);
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            decoration: BoxDecoration(
                                              color: _.selectedEntityType
                                                          .value ==
                                                      EntityType.worship.name
                                                  ? colorGreenSemiLight
                                                      .withValues(alpha: 0.12)
                                                  : Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: _.selectedEntityType
                                                            .value ==
                                                        EntityType.worship.name
                                                    ? colorGreenSemiLight
                                                    : Colors.grey[300]!,
                                                width: _.selectedEntityType
                                                            .value ==
                                                        EntityType.worship.name
                                                    ? 2
                                                    : 1,
                                              ),
                                              boxShadow: _.selectedEntityType
                                                          .value ==
                                                      EntityType.worship.name
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            colorGreenSemiLight
                                                                .withValues(alpha: 
                                                                    0.2),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: _.selectedEntityType
                                                                    .value ==
                                                                EntityType
                                                                    .worship
                                                                    .name
                                                            ? colorGreenSemiLight
                                                            : Colors.grey[300],
                                                        boxShadow:
                                                            _.selectedEntityType
                                                                        .value ==
                                                                    EntityType
                                                                        .worship
                                                                        .name
                                                                ? [
                                                                    BoxShadow(
                                                                      color: colorGreenSemiLight
                                                                          .withValues(alpha: 
                                                                              0.3),
                                                                      blurRadius:
                                                                          8,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              3),
                                                                    ),
                                                                  ]
                                                                : [],
                                                      ),
                                                      child: Icon(
                                                        Icons.church_outlined,
                                                        color:
                                                            _.selectedEntityType
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
                                                    const SizedBox(height: 12),
                                                    Text(
                                                      'PAROISSE',
                                                      style: TextStyles
                                                          .montserratBold(
                                                        textColor:
                                                            _.selectedEntityType
                                                                        .value ==
                                                                    EntityType
                                                                        .worship
                                                                        .name
                                                                ? colorGreenSemiLight
                                                                : Colors
                                                                    .grey[700]!,
                                                        textSize:
                                                            TextSizes.fifteen,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (_.selectedEntityType
                                                        .value ==
                                                    EntityType.worship.name)
                                                  const Positioned(
                                                    top: -20,
                                                    right: 10,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.only(top: 8),
                                                      child: Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color:
                                                            colorGreenSemiLight,
                                                        size: 20,
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

                            // Parish selection section (visible only if PAROISSE is selected)
                            if (_.selectedEntityType.value ==
                                EntityType.worship.name)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 24),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: colorGreenSemiLight
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                          style: TextStyles.montserratSemiBold(
                                            textColor: colorGreenSemiLight,
                                            textSize: TextSizes.sixteen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        _.goToWorshipChoice();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: _.paroisseSelected.value
                                                        .identifier !=
                                                    null
                                                ? colorGreenSemiLight
                                                : Colors.grey[300]!,
                                            width: _.paroisseSelected.value
                                                        .identifier !=
                                                    null
                                                ? 2
                                                : 1,
                                          ),
                                          boxShadow: _.paroisseSelected.value
                                                      .identifier !=
                                                  null
                                              ? [
                                                  BoxShadow(
                                                    color: colorGreenSemiLight
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: _.paroisseSelected.value
                                                          .identifier ==
                                                      null
                                                  ? Text(
                                                      'Sélectionner une paroisse',
                                                      style: TextStyles
                                                          .montserratMedium(
                                                        textColor:
                                                            Colors.grey[600]!,
                                                        textSize:
                                                            TextSizes.fifteen,
                                                      ),
                                                    )
                                                  : Text(
                                                      '${_.paroisseSelected.value.name}',
                                                      style: TextStyles
                                                          .montserratSemiBold(
                                                        textColor: colorBlack,
                                                        textSize:
                                                            TextSizes.fifteen,
                                                      ),
                                                    ),
                                            ),
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: colorGreenSemiLight
                                                    .withValues(alpha: 0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _.paroisseSelected.value
                                                            .identifier !=
                                                        null
                                                    ? Icons.edit_rounded
                                                    : Icons
                                                        .arrow_forward_ios_rounded,
                                                size: 18,
                                                color: colorGreenSemiLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Amount section
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colorGreenSemiLight
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                        style: TextStyles.montserratSemiBold(
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
                                      color:
                                          colorGreenSemiLight.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
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
                                            style: TextStyles.montserratMedium(
                                              textColor: colorGreenSemiLight,
                                              textSize: TextSizes.fourteen,
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
                                          _, '1 000', '1000'),
                                      const SizedBox(width: 8),
                                      _buildQuickAmountButton(
                                          _, '5 000', '5000'),
                                      const SizedBox(width: 8),
                                      _buildQuickAmountButton(
                                          _, '10 000', '10000'),
                                      const SizedBox(width: 8),
                                      _buildQuickAmountButton(
                                          _, '20 000', '20000'),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Description section
                            Container(
                              margin: const EdgeInsets.only(bottom: 30),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colorGreenSemiLight
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                        style: TextStyles.montserratSemiBold(
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
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child:
                                        const DonationDescriptionWithWorshipWidget(),
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

                            // Confirmation button
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 40),
                              height: 60,
                              child: CustomButton(
                                text: 'Continuer',
                                borderRadius: 16,
                                textSize: TextSizes.seventeen,
                                bgcolor: _.isValidForm.isTrue
                                    ? colorGreenSemiLight
                                    : Colors.grey[300]!,
                                borderColor: _.isValidForm.isTrue
                                    ? colorGreenSemiLight
                                    : Colors.grey[300]!,
                                textColor: _.isValidForm.isTrue
                                    ? colorWhite
                                    : Colors.grey[500]!,
                                actionColor:
                                    colorGreenSemiLight.withValues(alpha: 0.8),
                                enabled: _.isValidForm.value,
                                action: () {
                                  _.doSendDonation();
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
          ),
        );
      }),
    );
  }

  Widget _buildQuickAmountButton(DonationWithWorshipController controller, String displayAmount, String amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.amountController.text = amount;
          controller.checkForm();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            displayAmount,
            style: TextStyles.montserratSemiBold(
              textColor: colorGreenSemiLight,
              textSize: TextSizes.fourteen,
            ),
          ),
        ),
      ),
    );
  }
}
