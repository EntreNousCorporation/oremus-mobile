import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorGrey4,
      body: GetX<ProfileController>(builder: (_) {
        return PopScope(
          canPop: _.unlockBackButton.value,
          child: AbsorbPointer(
            absorbing: _.lockScreen.value,
            child: KeyboardDismisser(
              child: Stack(
                children: [
                  // Header background with gradient
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: colorGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                  ),

                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // Custom app bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: colorWhite,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Mon profil',
                                    style: TextStyles.montserratBold(
                                      textColor: colorWhite,
                                      textSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _.goToEditProfile();
                                  },
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    color: colorWhite,
                                    size: 20,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // Main content area
                        Expanded(
                          child: SmartRefresher(
                            controller: _.refreshController,
                            onRefresh: _.getProfile,
                            header: const CustomClassicHeader(
                              textColor: colorWhite,
                            ),
                            child: _.isDataProcessing.isTrue
                                ? Center(
                                    child: LottieLoadingView(
                                      size: Get.width / 4,
                                    ),
                                  )
                                : _.hasData.isTrue
                                    ? _buildProfileContent(_, context)
                                    : _.hasError.isTrue
                                        ? NotFoundScreen(
                                            message: _.errorMessage.value,
                                            doAction: () {
                                              _.getProfile();
                                            },
                                          )
                                        : NotFoundScreen(
                                            message:
                                                "Aucune information trouvée !",
                                            buttonTitle: 'Rafraîchir',
                                            doAction: () {
                                              _.getProfile();
                                            },
                                          ),
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

  Widget _buildProfileContent(
      ProfileController controller, BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (notification) {
        notification.disallowIndicator();
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FadeIn(
          child: Column(
            children: [
              // Profile header with avatar
              _buildProfileHeader(controller),

              // Profile actions section
              Padding(
                padding: const EdgeInsets.only(
                  top: 64.0,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 12),
                      child: Text(
                        'Paramètres du compte',
                        style: TextStyles.montserratBold(
                          textSize: 16,
                          textColor: colorGreenSemiLight,
                        ),
                      ),
                    ),

                    // Profile action cards
                    _buildActionCard(
                      icon: Icons.favorite,
                      title: 'Mes favoris',
                      onTap: () => controller.goToFavorites(),
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      icon: Icons.lock,
                      title: 'Modifier votre mot de passe',
                      onTap: () => controller.goToEditPassword(),
                      tag: 'update-password',
                    ),

                    /*
                    const SizedBox(height: 12),

                    // Biometric login card (currently hidden)
                    Visibility(
                      visible: false,
                      child: _buildBiometricCard(controller),
                    ),
                    */

                    const SizedBox(height: 40),

                    // Delete account button (redesigned)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          controller.showDeleteAccountDialog();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: colorRed1.withValues(alpha: 0.3)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: colorRed1.withValues(alpha: 0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Supprimer mon compte',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorRed1.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Top spacing
        const SizedBox(height: 120),

        // User info card
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Container(
            width: Get.width,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${controller.userInfo.value.firstname} ${controller.userInfo.value.lastname}',
                  style: TextStyles.montserratMedium(
                    textSize: 20,
                    textColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.userInfo.value.email}',
                  style: TextStyles.montserratMedium(
                    textSize: 16,
                    textColor: Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.userInfo.value.phone?.phoneFormat()}',
                  style: TextStyles.montserratMedium(
                    textSize: 16,
                    textColor: Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Avatar
        Positioned(
          top: 0,
          child: Hero(
            tag: 'avatar',
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: 120,
                    height: 120,
                    color: colorGreen1.withValues(alpha: 0.3),
                    child: SvgPicture.asset(Assets.imagesAvatar),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? tag,
  }) {
    Widget titleWidget = Text(
      title,
      style: TextStyles.montserratMedium(
        textSize: 16,
        textColor: Colors.black87,
      ),
    );

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorGreen1.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorGreenSemiLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: tag != null
                    ? Hero(tag: tag, child: titleWidget)
                    : titleWidget,
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricCard(ProfileController controller) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorGreen1.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: colorGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Connexion biométrique',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              activeColor: colorGreen,
              value: controller.isActive.value,
              onChanged: (value) {
                controller.updateBiometriqueUI();
                controller.showMessageBiometrique(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
