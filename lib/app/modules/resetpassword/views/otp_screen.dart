import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/otp_controller.dart';
import 'package:oremusapp/app/modules/resetpassword/views/widgets/otp_field.dart';
import 'package:oremusapp/generated/assets.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.imagesBgLogin),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: GetX<OtpController>(
          builder: (_) {
            return FadeIn(
              preferences: const AnimationPreferences(
                duration: Duration(milliseconds: 800),
                offset: Duration(milliseconds: 300),
              ),
              child: KeyboardDismisser(
                child: Scaffold(
                  backgroundColor: Colors.black.withOpacity(0.3),
                  resizeToAvoidBottomInset: true,
                  body: PopScope(
                    canPop: _.unlockBackButton.value,
                    child: AbsorbPointer(
                      absorbing: _.lockScreen.value,
                      child: Stack(
                        children: [
                          // Back Button with animation
                          Positioned(
                            top: Get.mediaQuery.padding.top + 20,
                            left: 24,
                            child: ZoomIn(
                              preferences: const AnimationPreferences(
                                duration: Duration(milliseconds: 600),
                                offset: Duration(milliseconds: 200),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: colorGreen,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Title with elegant styling
                          Positioned(
                            top: Get.mediaQuery.padding.top + 20,
                            left: 0,
                            right: 0,
                            child: FadeInDown(
                              preferences: const AnimationPreferences(
                                duration: Duration(milliseconds: 800),
                                offset: Duration(milliseconds: 400),
                              ),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: colorGreen.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorGreen.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "Vérification",
                                    style: TextStyles.montserratBold(
                                      textSize: TextSizes.twenty,
                                      textColor: colorWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Main Content
                          SafeArea(
                            bottom: false,
                            child: Center(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  child: FadeInUp(
                                    preferences: const AnimationPreferences(
                                      duration: Duration(milliseconds: 800),
                                      offset: Duration(milliseconds: 400),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Icon
                                        Container(
                                          height: 80,
                                          width: 80,
                                          margin: const EdgeInsets.only(bottom: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: colorGreen.withOpacity(0.3),
                                                blurRadius: 20,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.password_rounded,
                                              color: colorGreen,
                                              size: 40,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // Form Container with elegant styling
                                        SlideInUp(
                                          preferences: const AnimationPreferences(
                                            duration: Duration(milliseconds: 800),
                                            offset: Duration(milliseconds: 500),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: Colors.white.withOpacity(0.97),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.15),
                                                  blurRadius: 25,
                                                  offset: const Offset(0, 10),
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                            child: Form(
                                              key: _.formSigninKey,
                                              child: Padding(
                                                padding: const EdgeInsets.all(30),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    // Title and instructions
                                                    Text(
                                                      "Code de vérification",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyles.montserratBold(
                                                        textSize: TextSizes.twenty,
                                                        textColor: colorGreen,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 15),

                                                    RichText(
                                                      textAlign: TextAlign.center,
                                                      text: TextSpan(
                                                        text: 'Veuillez saisir le code de vérification envoyé à l\'adresse\n',
                                                        style: TextStyles.montserratRegular(
                                                            textSize: TextSizes.fourteen,
                                                            textColor: Colors.grey[600]!
                                                        ),
                                                        children: <TextSpan>[
                                                          TextSpan(
                                                            text: _.usernameEntered.value,
                                                            style: TextStyles.montserratSemiBold(
                                                                textSize: TextSizes.fourteen,
                                                                textColor: colorGreen
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    // OTP Field with animated styling
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                                      decoration: BoxDecoration(
                                                        color: colorGreen.withOpacity(0.05),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: OtpField(
                                                          controller: _,
                                                          otpLength: _.otpLength.value
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    // Submit Button
                                                    Container(
                                                      width: double.infinity,
                                                      height: 56,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(18),
                                                        gradient: LinearGradient(
                                                          colors: _.isValidForm.isTrue
                                                              ? [
                                                            colorGreen.withOpacity(0.9),
                                                            colorGreen,
                                                          ]
                                                              : [
                                                            Colors.grey[300]!,
                                                            Colors.grey[400]!,
                                                          ],
                                                          begin: Alignment.topLeft,
                                                          end: Alignment.bottomRight,
                                                        ),
                                                        boxShadow: _.isValidForm.isTrue
                                                            ? [
                                                          BoxShadow(
                                                            color: colorGreen.withOpacity(0.3),
                                                            blurRadius: 15,
                                                            offset: const Offset(0, 8),
                                                            spreadRadius: 0,
                                                          ),
                                                        ]
                                                            : [],
                                                      ),
                                                      child: TextButton(
                                                        onPressed: _.isValidForm.isTrue
                                                            ? () {
                                                          _.doCheckOtp();
                                                        }
                                                            : null,
                                                        style: TextButton.styleFrom(
                                                          foregroundColor: Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(18),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              "Vérifier",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                letterSpacing: 0.5,
                                                                color: _.isValidForm.isTrue
                                                                    ? Colors.white
                                                                    : Colors.grey[500],
                                                              ),
                                                            ),
                                                            const SizedBox(width: 10),
                                                            SvgPicture.asset(
                                                              'assets/images/icon_arrow_right.svg',
                                                              width: 20,
                                                              height: 20,
                                                              colorFilter: ColorFilter.mode(
                                                                _.isValidForm.isTrue
                                                                    ? Colors.white
                                                                    : Colors.grey[500]!,
                                                                BlendMode.srcIn,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    // Resend code option
                                                    TextButton(
                                                      onPressed: () {
                                                        // Action de renvoi du code
                                                      },
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Icon(
                                                            Icons.refresh_rounded,
                                                            color: colorPurpleLight,
                                                            size: 16,
                                                          ),
                                                          const SizedBox(width: 5),
                                                          Text(
                                                            "Renvoyer le code",
                                                            style: TextStyles.montserratMedium(
                                                              textSize: TextSizes.fourteen,
                                                              textColor: colorPurpleLight,
                                                            ),
                                                          ),
                                                        ],
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
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
