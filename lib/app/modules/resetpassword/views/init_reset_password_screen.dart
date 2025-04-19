import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/init_reset_password_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class InitResetPasswordScreen extends StatelessWidget {
  const InitResetPasswordScreen({Key? key}) : super(key: key);

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
        child: GetX<InitResetPasswordController>(
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
                  body: WillPopScope(
                    onWillPop: () async => _.unlockBackButton.value,
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
                                    "Mot de passe oublié",
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
                                              Icons.lock_reset_rounded,
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
                                                      "Réinitialiser votre mot de passe",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyles.montserratBold(
                                                        textSize: TextSizes.twenty,
                                                        textColor: colorGreen,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 15),

                                                    Text(
                                                      "Veuillez entrer votre adresse email. Nous vous enverrons un code de vérification pour réinitialiser votre mot de passe.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyles.montserratRegular(
                                                        textSize: TextSizes.fourteen,
                                                        textColor: Colors.grey[600]!,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    // Email Field with enhanced styling
                                                    MyTextField(
                                                      focusNode: _.emailFocusNode,
                                                      controller: _.emailController,
                                                      hintText: 'Votre adresse email',
                                                      labelText: 'E-mail',
                                                      prefixIcon: "assets/images/icon_enveloppe.svg",
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.grey[50],
                                                      //borderRadius: 16,
                                                      keyboardType: TextInputType.emailAddress,
                                                      textCapitalization: TextCapitalization.none,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.emailErrorMessage.value,
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
                                                          _.doInitResetPassword();
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
                                                              "Envoyer",
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
