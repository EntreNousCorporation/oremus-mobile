import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_presby_team_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/presby_team_item.dart';
import 'package:oremusapp/generated/assets.dart';

class ParoisseBresbyTeamScreen extends StatelessWidget {
  const ParoisseBresbyTeamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<ParoissePresbyTeamController>(
          builder: (controller) {
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
                            },
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: colorWhite,
                              size: 22,
                            ),
                          ),
                        ),
                        // Actions (signaler, favoris, carte)
                        actions: [
                          // Bouton signaler un problème
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                controller.goToReportProblem();
                              },
                              icon: SvgPicture.asset(
                                Assets.imagesWarning,
                                colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                height: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

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
                              '${controller.paroisseSelected.value.name}',
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

                      // Section de titre
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorGreenSemiLight.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  Assets.imagesPriestIcon,
                                  colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn),
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Hero(
                                      tag: controller.code.value,
                                      child: Text(
                                        controller.getTypeTitle(controller.code.value),
                                        style: TextStyles.montserratBold(
                                          textSize: TextSizes.seventeen,
                                          textColor: colorGreenSemiLight,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Membres de l\'équipe pastorale',
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
                      ),

                      // Contenu principal (liste des membres de l'équipe)
                      controller.isDataProcessing.isTrue
                          ? SliverFillRemaining(
                        child: Center(
                          child: LottieLoadingView(
                            size: Get.width / 4,
                          ),
                        ),
                      )
                          : controller.hasData.isTrue
                          ? SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              var user = controller.presbyTeams[index];
                              return PresbyTeamItem(user: user);
                            },
                            childCount: controller.presbyTeams.length,
                          ),
                        ),
                      )
                          : SliverFillRemaining(
                        child: _buildEmptyState(controller.getTypeMessage(controller.code.value)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  // État vide amélioré
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: colorGreen.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyles.montserratBold(
              textSize: TextSizes.eighteen,
              textColor: colorGreenSemiLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}