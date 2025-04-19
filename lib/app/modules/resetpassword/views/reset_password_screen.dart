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
import 'package:oremusapp/app/modules/resetpassword/controller/reset_password_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

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
        child: GetX<ResetPasswordController>(
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
                                    "Nouveau mot de passe",
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
                                              Icons.key_rounded,
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
                                                      "Créer un nouveau mot de passe",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyles.montserratBold(
                                                        textSize: TextSizes.twenty,
                                                        textColor: colorGreen,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 15),

                                                    Text(
                                                      "Votre nouveau mot de passe doit être différent de vos anciens mots de passe.",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyles.montserratRegular(
                                                        textSize: TextSizes.fourteen,
                                                        textColor: Colors.grey[600]!,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    // Password Fields
                                                    Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.all(15),
                                                      decoration: BoxDecoration(
                                                        color: colorGreen.withOpacity(0.05),
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(
                                                          color: colorGreen.withOpacity(0.1),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 8, bottom: 10),
                                                            child: Text(
                                                              "Sécurité",
                                                              style: TextStyles.montserratSemiBold(
                                                                textSize: TextSizes.fourteen,
                                                                textColor: colorGreen,
                                                              ),
                                                            ),
                                                          ),

                                                          // New Password Field
                                                          MyTextField(
                                                            focusNode: _.newPasswordFocusNode,
                                                            controller: _.newPasswordController,
                                                            hintText: 'Votre nouveau mot de passe',
                                                            labelText: 'Nouveau mot de passe',
                                                            isPassword: true,
                                                            prefixIcon: 'assets/images/icon_password_profil.svg',
                                                            prefixIconColor: colorGreen,
                                                            //textFieldColor: Colors.white,
                                                            //borderRadius: 16,
                                                            onChanged: (value) {
                                                              _.checkForm();
                                                            },
                                                            errorText: _.newPasswordErrorMessage.value,
                                                          ),

                                                          const SizedBox(height: 15),

                                                          // Confirm Password Field
                                                          MyTextField(
                                                            focusNode: _.confPasswordFocusNode,
                                                            controller: _.confPasswordController,
                                                            hintText: 'Confirmez votre mot de passe',
                                                            labelText: 'Confirmer le mot de passe',
                                                            isPassword: true,
                                                            prefixIcon: 'assets/images/icon_password_profil.svg',
                                                            prefixIconColor: colorGreen,
                                                            //textFieldColor: Colors.white,
                                                            //borderRadius: 16,
                                                            onChanged: (value) {
                                                              _.checkForm();
                                                            },
                                                            errorText: _.confPasswordErrorMessage.value,
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(height: 30),

                                                    // Password Rules
                                                    Visibility(
                                                      visible: false,
                                                      child: Container(
                                                        width: double.infinity,
                                                        padding: const EdgeInsets.all(15),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[50],
                                                          borderRadius: BorderRadius.circular(16),
                                                          border: Border.all(
                                                            color: Colors.grey[300]!,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              "Le mot de passe doit contenir:",
                                                              style: TextStyles.montserratMedium(
                                                                textSize: TextSizes.fourteen,
                                                                textColor: Colors.grey[700]!,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 8),
                                                            _buildPasswordRule("Au moins 8 caractères"),
                                                            _buildPasswordRule("Une lettre majuscule"),
                                                            _buildPasswordRule("Une lettre minuscule"),
                                                            _buildPasswordRule("Un chiffre"),
                                                            _buildPasswordRule("Un caractère spécial"),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    //const SizedBox(height: 30),

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
                                                          _.doResetPassword();
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
                                                              "Réinitialiser",
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

  // Helper method to build password rule items
  Widget _buildPasswordRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: colorGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyles.montserratRegular(
              textSize: TextSizes.thirteen,
              textColor: Colors.grey[600]!,
            ),
          ),
        ],
      ),
    );
  }
}