import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return GetX<DonationController>(builder: (controller) {
      return KeyboardDismisser(
        child: PopScope(
          canPop: controller.unlockBackButton.value,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.grey[50],
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
                    snap: false,
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
                    actions: [
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
                            end: Color(0xFFED213A),
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
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          controller.paroisseSelected.value.name ?? '-',
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
                              // Cover image
                              (controller.paroisseSelected.value.coverImage?.link?.isNotEmpty == true)
                                  ? CachedNetworkImage(
                                imageUrl: controller.paroisseSelected.value.coverImage?.link ?? '',
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
                              // Gradient overlay
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

                  // Main content section
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Title section with enhanced design
                        Row(
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
                              child: SvgPicture.asset(
                                Assets.imagesVolunteer,
                                colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    'Soutenez votre paroisse',
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
                        const SizedBox(height: 24),

                        // Amount section
                        _buildEnhancedSection(
                          title: 'Montant',
                          icon: Icons.payments_rounded,
                          child: const AmountWidget(),
                          notes: [
                            _buildNoteRow(
                              icon: Icons.info_outline_rounded,
                              text: 'Le montant minimum est de 100 FCFA',
                            ),
                          ],
                          // Quick amount buttons
                          extraContent: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                  _buildQuickAmountButton(controller, '1 000', '1 000'),
                                  const SizedBox(width: 8),
                                  _buildQuickAmountButton(controller, '5 000', '5 000'),
                                  const SizedBox(width: 8),
                                  _buildQuickAmountButton(controller, '10 000', '10 000'),
                                  const SizedBox(width: 8),
                                  _buildQuickAmountButton(controller, '20 000', '20 000'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description section
                        _buildEnhancedSection(
                          title: 'Description',
                          icon: Icons.description_outlined,
                          child: const DonationDescriptionWidget(),
                          extraContent: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Décrivez l\'intention de votre don (optionnel)',
                              style: TextStyles.montserratRegular(
                                textColor: Colors.grey[600]!,
                                textSize: TextSizes.thirteen,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Continue button with enhanced style
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: CustomButton(
                            text: 'Continuer',
                            borderRadius: 16,
                            textSize: TextSizes.seventeen,
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
                              controller.doSendDonation();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                      ]),
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

  // Enhanced section builder with icon and title
  Widget _buildEnhancedSection({
    required String title,
    required IconData icon,
    required Widget child,
    List<Widget> notes = const [],
    Widget? extraContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorGreenSemiLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyles.montserratSemiBold(
                  textColor: colorGreenSemiLight,
                  textSize: TextSizes.sixteen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...notes,
          ],
          if (extraContent != null) extraContent,
        ],
      ),
    );
  }

  // Enhanced note row
  Widget _buildNoteRow({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorGreenSemiLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorGreenSemiLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorGreenSemiLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyles.montserratMedium(
                textColor: colorGreenSemiLight,
                textSize: TextSizes.fourteen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(DonationController controller, String displayAmount, String amount) {
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
                  : Colors.grey[50],
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
