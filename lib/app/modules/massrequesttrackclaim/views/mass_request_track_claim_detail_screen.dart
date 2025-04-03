import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_detail_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestTrackClaimDetailScreen extends StatelessWidget {
  const MassRequestTrackClaimDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: GetX<MassRequestTrackClaimDetailController>(builder: (_) {
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
                    // Title and background image
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          _.paroisseSelected.value.name ?? '',
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
                              (_.paroisseSelected.value.coverImage?.link?.isNotEmpty == true)
                                  ? CachedNetworkImage(
                                width: Get.width,
                                height: Get.width,
                                imageUrl: _.paroisseSelected.value.coverImage?.link ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => LottieLoadingView(size: Get.width / 6),
                                errorWidget: (context, url, error) => Image.asset(
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

                  // Claim details content
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
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
                                    Icons.info_outline_rounded,
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
                                        'Détails réclamation',
                                        style: TextStyles.montserratBold(
                                          textSize: TextSizes.eighteen,
                                          textColor: colorGreenSemiLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Informations sur votre demande',
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

                          // Status icon and text
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
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
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: getColor(_.claimSelected.value?.status?.code).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: getColor(_.claimSelected.value?.status?.code).withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    getIcon(_.claimSelected.value?.status?.code),
                                    color: getColor(_.claimSelected.value?.status?.code),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: getColor(_.claimSelected.value?.status?.code).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _.claimSelected.value?.status?.name?.fr ?? '-',
                                    style: TextStyles.montserratBold(
                                      textSize: TextSizes.sixteen,
                                      textColor: getColor(_.claimSelected.value?.status?.code),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Claim details card
                          Container(
                            width: double.infinity,
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
                              children: [
                                // Detail items
                                _buildDetailItem(
                                  title: 'Paroisse',
                                  value: _.claimSelected.value?.massRequest?.worshipPlace?.name ?? '-',
                                  icon: Icons.church_outlined,
                                ),
                                _buildDivider(),

                                _buildDetailItem(
                                  title: 'Type de réclamation',
                                  value: _.claimSelected.value?.typeOfClaim?.name?.fr ?? '-',
                                  icon: Icons.category_outlined,
                                ),
                                _buildDivider(),

                                _buildDetailItem(
                                  title: 'Description de la réclamation',
                                  value: _.claimSelected.value?.description ?? '-',
                                  icon: Icons.description_outlined,
                                  isLongText: true,
                                ),
                                _buildDivider(),

                                _buildDetailItem(
                                  title: 'Créée le',
                                  value: getDateTime(_.claimSelected.value?.createdAt ?? ' - '),
                                  icon: Icons.calendar_today_rounded,
                                ),
                                _buildDivider(),

                                _buildDetailItem(
                                  title: 'Modifiée le',
                                  value: getDateTime(_.claimSelected.value?.updatedAt ?? ' - '),
                                  icon: Icons.update_rounded,
                                ),

                                // Show observation only if it exists
                                if ((_.claimSelected.value?.observation ?? '').isNotEmpty) ...[
                                  _buildDivider(),
                                  _buildDetailItem(
                                    title: 'Observation',
                                    value: _.claimSelected.value?.observation ?? '-',
                                    icon: Icons.comment_outlined,
                                    isLongText: true,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
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

  // Helper method to create detail item rows
  Widget _buildDetailItem({
    required String title,
    required String value,
    required IconData icon,
    bool isLongText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colorGreenSemiLight,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.fourteen,
                  textColor: Colors.grey[700]!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Value with appropriate styling
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(
              value,
              style: TextStyles.montserratSemiBold(
                textSize: isLongText ? TextSizes.fifteen : TextSizes.sixteen,
                textColor: Colors.black87,
              ),
              textAlign: isLongText ? TextAlign.start : TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create dividers
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey[200],
        height: 1,
      ),
    );
  }
}
