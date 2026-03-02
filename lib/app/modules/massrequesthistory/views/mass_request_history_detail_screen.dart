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
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/mass_request_state_view.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';

class MassRequestHistoryDetailScreen extends StatelessWidget {
  const MassRequestHistoryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<MassRequestHistoryDetailController>(builder: (controller) {
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
                    // Actions (favoris, carte)
                    actions: requestMassWithoutWorship.value
                        ? null
                        : [
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
                              controller.removeFavorite(
                                  controller.paroisseSelected.value, isLiked);
                            } else {
                              controller.saveFavorite(
                                  controller.paroisseSelected.value, isLiked);
                            }
                            return !isLiked;
                          },
                          size: 25,
                          circleColor: const CircleColor(
                              start: Color(0xff93291E),
                              end: Color(0xFFED213A)),
                          bubblesColor: const BubblesColor(
                            dotPrimaryColor: Color(0xFFED213A),
                            dotSecondaryColor: Color(0xff93291E),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isLiked
                                  ? const Color(0xFFED213A)
                                  : colorWhite,
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
                          controller.paroisseSelected.value.name ?? '',
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

                  // Contenu principal (détails de la demande)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        children: [
                          // Indicateur de statut avec animation subtile
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: child,
                              );
                            },
                            child: Column(
                              children: [
                                // Icône de statut
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: getColor(controller.massRequestSelected.value.status?.code).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: getColor(controller.massRequestSelected.value.status?.code),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: getColor(controller.massRequestSelected.value.status?.code).withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    getIcon(controller.massRequestSelected.value.status?.code),
                                    color: getColor(controller.massRequestSelected.value.status?.code),
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Texte de statut
                                Text(
                                  controller.massRequestSelected.value.status?.name?.fr ?? '-',
                                  textAlign: TextAlign.center,
                                  style: TextStyles.montserratBold(
                                    textSize: TextSizes.twenty,
                                    textColor: getColor(controller.massRequestSelected.value.status?.code),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Carte d'informations
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Section référence
                                _buildInfoSection(
                                  label: 'Référence',
                                  value: controller.massRequestSelected.value.traceId ?? '-',
                                  icon: Icons.numbers_rounded,
                                  isFirst: true,
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section type de demande
                                _buildInfoSection(
                                  label: 'Type de demande',
                                  value: controller.massRequestSelected.value.typeOfMassRequest?.name?.fr ?? '-',
                                  icon: Icons.category_rounded,
                                  isFirst: false,
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section date
                                _buildInfoSection(
                                  label: 'Date',
                                  value: getCustomDate(controller.massRequestSelected.value.createdAt ?? ''),
                                  icon: Icons.calendar_today_rounded,
                                  isFirst: false,
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section montant
                                _buildInfoSection(
                                  label: 'Montant',
                                  value: '${controller.massRequestSelected.value.price.toString().split('.').first.amountFormat()} FCFA',
                                  icon: Icons.payments_rounded,
                                  isFirst: false,
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section intention de prière
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: colorGreen.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.emoji_people_rounded,
                                              color: colorGreen,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          Text(
                                            'Intention de prière',
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.fifteen,
                                              textColor: colorBlack,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: colorGreen.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          controller.massRequestSelected.value.prayerIntent ?? '-',
                                          style: TextStyles.montserratRegular(
                                            textSize: TextSizes.fourteen,
                                            textColor: colorBlack,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Bouton afficher les horaires
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.showMassHours();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: colorGreen.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: colorGreen.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            color: colorGreen,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Afficher les horaires',
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.fourteen,
                                              textColor: colorGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Boutons d'actions
                          if (controller.canClaimMassRequest()) ...[
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Bouton réclamation
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.moveToMassRequestClaims(controller.massRequestSelected.value);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: colorTurquois,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.03),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.real_estate_agent_rounded,
                                            color: colorTurquois,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Faire\nune réclamation',
                                            textAlign: TextAlign.center,
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.thirteen,
                                              textColor: colorTurquois,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Bouton répéter
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.moveToMassRequest(controller.massRequestSelected.value);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: colorTurquois,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorTurquois.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.repeat_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Répéter\ncette demande',
                                            textAlign: TextAlign.center,
                                            style: TextStyles.montserratSemiBold(
                                              textSize: TextSizes.thirteen,
                                              textColor: Colors.white,
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

                          // Section de statuts (si disponible)
                          if (controller.massRequestStatuses.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colorGreen.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.timeline_rounded,
                                          size: 20,
                                          color: colorGreen,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Suivi de la demande',
                                        style: TextStyles.montserratBold(
                                          textSize: TextSizes.sixteen,
                                          textColor: colorBlack,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Timeline des statuts
                                  const MassRequestStateView(),
                                ],
                              ),
                            ),
                          ],
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

  // Séparateur pour les sections
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }

  // Section d'information
  Widget _buildInfoSection({
    required String label,
    required String value,
    required IconData icon,
    required bool isFirst,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icône
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colorGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Textes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Libellé
                Text(
                  label,
                  style: TextStyles.montserratRegular(
                    textSize: TextSizes.thirteen,
                    textColor: Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 4),

                // Valeur
                Text(
                  value,
                  style: TextStyles.montserratSemiBold(
                    textSize: TextSizes.fifteen,
                    textColor: colorBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}