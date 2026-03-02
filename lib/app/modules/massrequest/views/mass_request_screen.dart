import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
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
    return GetX<MassRequestController>(builder: (controller) {
      return KeyboardDismisser(
        child: PopScope(
          canPop: controller.unlockBackButton.value,
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
                  // En-tête extensible avec image de couverture
                  SliverAppBar(
                    expandedHeight: AppConstants.kExpandedHeight,
                    collapsedHeight: 100,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorGreen,
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    // Bouton retour
                    leading: Container(
                      margin: const EdgeInsets.only(left: 8, top: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                          Get.delete<FilterMassRequestDateController>(force: true);
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: colorWhite,
                          size: 22,
                        ),
                      ),
                    ),
                    // Actions (favoris, carte)
                    actions: [
                      // Bouton favoris
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
                      // Bouton carte
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
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                              // Image de couverture
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
                              // Superposition ombrée
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
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

                  // Formulaire de demande de messe
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // Titre principal
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorGreenSemiLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorGreenSemiLight.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorGreenSemiLight.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.church_outlined,
                                    color: colorGreenSemiLight,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Faire une demande de messe',
                                        style: TextStyles.montserratBold(
                                          textSize: TextSizes.sixteen,
                                          textColor: colorGreenSemiLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Veuillez compléter tous les champs',
                                        style: TextStyles.montserratRegular(
                                          textSize: TextSizes.thirteen,
                                          textColor: Colors.grey[600]!,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Section type de demande
                          _buildSectionTitle(
                            icon: Icons.category_outlined,
                            title: 'Type de demande de messe',
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            content: const MassTypeFilter(),
                          ),
                          const SizedBox(height: 24),

                          // Section répétition
                          _buildSectionTitle(
                            icon: Icons.repeat_outlined,
                            title: 'Répétition',
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            content: const MassTypeRepetitionFilter(),
                          ),
                          const SizedBox(height: 24),

                          // Section dates multiples (conditionnelle)
                          if (controller.massRequestTypeRepetitionSelected.value?.code == RepetitionType.many.name) ...[
                            _buildSelectionCard(
                              onTap: () {
                                controller.goToDatesChoice();
                              },
                              content: controller.isDatesProcessing.isTrue
                                  ? const ShimmerPrice(height: 50)
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Choisir les horaires de messe',
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorGrey1,
                                      textSize: TextSizes.fifteen,
                                    ),
                                  ),
                                  Icon(
                                    (controller.datesChoosen.isNotEmpty &&
                                        controller.massRequestTypeRepetitionSelected.value?.code == RepetitionType.many.name)
                                        ? Icons.check_circle
                                        : Icons.calendar_month,
                                    size: 22,
                                    color: controller.worshipHours.isNotEmpty
                                        ? colorGreen
                                        : colorGrey1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Section date unique (conditionnelle)
                          if (controller.massRequestTypeRepetitionSelected.value?.code == RepetitionType.once.name) ...[
                            _buildSectionTitle(
                              icon: Icons.event_outlined,
                              title: 'Date et heure',
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              content: Row(
                                children: [
                                  // Date
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (controller.selectedDate.value == null) return;
                                        controller.showPicker(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: controller.selectedDate.value != null
                                                ? colorGreen.withValues(alpha: 0.3)
                                                : Colors.red.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: controller.isDatesProcessing.isTrue
                                            ? const ShimmerPrice(height: 24)
                                            : Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 20,
                                              color: controller.selectedDate.value != null
                                                  ? colorGreen
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                controller.selectedDate.value?.dayToDisplay ?? 'Choisir une date',
                                                style: TextStyles.montserratSemiBold(
                                                  textColor: controller.selectedDate.value != null
                                                      ? colorBlack
                                                      : Colors.red,
                                                  textSize: TextSizes.fourteen,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Espace
                                  const SizedBox(width: 12),
                                  // Heure
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colorGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorGreen.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: const MassTypeHourFilter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Section intention de messe
                          _buildSectionTitle(
                            icon: Icons.message_outlined,
                            title: 'Intention de messe',
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            content: const IntentTypeDescriptionWidget(),
                          ),
                          const SizedBox(height: 32),

                          // Section tarif
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorGreenlight2,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: controller.isPricingProcessing.isTrue
                                ? const ShimmerPrice(height: 50)
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorGreen.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: colorGreen,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tarif',
                                      style: TextStyles.montserratMedium(
                                        textColor: colorGreySeparator,
                                        textSize: TextSizes.fourteen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.getPrice().value,
                                      style: TextStyles.montserratBold(
                                        textColor: colorBlack,
                                        textSize: TextSizes.twenty_four,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Bouton continuer
                          CustomButton(
                            text: 'Continuer',
                            borderRadius: 12,
                            textSize: TextSizes.sixteen,
                            bgcolor: controller.isValidForm.isTrue
                                ? colorGreen
                                : colorGrey1.withValues(alpha: 0.5),
                            borderColor: controller.isValidForm.isTrue
                                ? colorGreen
                                : colorGreen.withValues(alpha: 0),
                            actionColor: colorGreen.withValues(alpha: 0.5),
                            enabled: controller.isValidForm.value,
                            action: () {
                              controller.doSendMassRequest();
                            },
                          ),
                          const SizedBox(height: 16),
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

  // Titre de section avec icône
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colorGreenSemiLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorGreenSemiLight,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyles.montserratSemiBold(
            textColor: colorGrey1,
            textSize: TextSizes.fifteen,
          ),
        ),
      ],
    );
  }

  // Carte de base pour les contenus
  Widget _buildCard({required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: content,
    );
  }

  // Carte cliquable pour les sélections
  Widget _buildSelectionCard({required VoidCallback onTap, required Widget content}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
