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
import 'package:oremusapp/app/modules/signin/controller/signin_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({Key? key}) : super(key: key);

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
        child: GetX<SigninController>(
          builder: (_) {
            return FadeIn(
              preferences: const AnimationPreferences(
                duration: Duration(milliseconds: 800),
                offset: Duration(milliseconds: 300),
              ),
              child: KeyboardDismisser(
                child: Scaffold(
                  backgroundColor: Colors.black.withValues(alpha:0.3),
                  resizeToAvoidBottomInset: false,
                  body: PopScope(
                    canPop: _.unlockBackButton.value,
                    child: AbsorbPointer(
                      absorbing: _.lockScreen.value,
                      child: Stack(
                        children: [
                          // Main Content
                          SafeArea(
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Logo section with animation
                                        Center(
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            margin: const EdgeInsets.only(bottom: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorGreen.withValues(alpha:0.3),
                                                  blurRadius: 20,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/images/logo.svg',
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Sign-in Title with elegant styling
                                        Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: colorGreen.withValues(alpha:0.9),
                                              borderRadius: BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorGreen.withValues(alpha:0.3),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              "S'identifier",
                                              style: TextStyles.montserratBold(
                                                textSize: TextSizes.twenty_four,
                                                textColor: colorWhite,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // Form Container with elegant styling and subtle animation
                                        SlideInUp(
                                          preferences: const AnimationPreferences(
                                            duration: Duration(milliseconds: 800),
                                            offset: Duration(milliseconds: 500),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: Colors.white.withValues(alpha:0.97),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha:0.15),
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
                                                    // Welcome Text with improved styling
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            color: colorGreen.withValues(alpha: 0.15),
                                                            shape: BoxShape.circle,
                                                            border: Border.all(
                                                              color: colorGreen.withValues(alpha:0.3),
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                            Icons.person_rounded,
                                                            color: colorGreen,
                                                            size: 28,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                "Bienvenue",
                                                                style: TextStyles.montserratBold(
                                                                  textSize: TextSizes.twenty_four,
                                                                  textColor: colorGreen,
                                                                ),
                                                              ),
                                                              Text(
                                                                "Connectez-vous à votre compte",
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

                                                    const SizedBox(height: 32),

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

                                                    const SizedBox(height: 20),

                                                    // Password Field with enhanced styling
                                                    MyTextField(
                                                      focusNode: _.passwordFocusNode,
                                                      controller: _.passwordController,
                                                      hintText: 'Votre mot de passe',
                                                      labelText: 'Mot de passe',
                                                      isPassword: true,
                                                      prefixIcon: 'assets/images/icon_password_profil.svg',
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.grey[50],
                                                      //borderRadius: 16,
                                                      textCapitalization: TextCapitalization.none,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.passwordErrorMessage.value,
                                                    ),

                                                    // Forgot Password Link with improved styling
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          _.goToForgotPassword();
                                                        },
                                                        style: TextButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 10, horizontal: 12),
                                                        ),
                                                        child: Text(
                                                          'Mot de passe oublié ?',
                                                          style: TextStyles.montserratSemiBold(
                                                            textSize: TextSizes.fourteen,
                                                            textColor: colorPurpleLight,
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 32),

                                                    // Sign-in Button with enhanced styling and animation
                                                    Hero(
                                                      tag: 'loginButton',
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        height: 56,
                                                        child: ElevatedButton(
                                                          onPressed: _.isValidForm.isTrue
                                                              ? () {
                                                            _.connectUser();
                                                          }
                                                              : null,
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: _.isValidForm.isTrue
                                                                ? colorGreen
                                                                : Colors.grey[300],
                                                            foregroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(18),
                                                            ),
                                                            elevation: _.isValidForm.isTrue ? 4 : 0,
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          child: AnimatedOpacity(
                                                            duration: const Duration(milliseconds: 300),
                                                            opacity: _.isValidForm.isTrue ? 1.0 : 0.7,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                const Text(
                                                                  "Se connecter",
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold,
                                                                    letterSpacing: 0.5,
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
                                                                        : Colors.grey[400]!,
                                                                    BlendMode.srcIn,
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

                                        const SizedBox(height: 30),

                                        // Registration Section with divider and text
                                        SlideInUp(
                                          preferences: const AnimationPreferences(
                                            duration: Duration(milliseconds: 800),
                                            offset: Duration(milliseconds: 600),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 1,
                                                      color: Colors.white.withValues(alpha:0.5),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                    child: Text(
                                                      "Pas encore de compte ?",
                                                      style: TextStyles.montserratMedium(
                                                        textSize: TextSizes.fourteen,
                                                        textColor: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 1,
                                                      color: Colors.white.withValues(alpha:0.5),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 20),

                                              // Registration Button with enhanced styling
                                              Center(
                                                child: Container(
                                                  width: Get.width * 0.7,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(18),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        colorGreen.withValues(alpha:0.9),
                                                        colorGreen,
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: colorGreen.withValues(alpha:0.3),
                                                        blurRadius: 15,
                                                        offset: const Offset(0, 8),
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: CustomButton(
                                                    text: "S'inscrire",
                                                    textSize: TextSizes.sixteen,
                                                    borderRadius: 18,
                                                    bgcolor: Colors.transparent,
                                                    borderColor: Colors.transparent,
                                                    actionColor: colorGreen.withValues(alpha:0.7),
                                                    action: () {
                                                      _.goToSignup();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Back/Home Button with animation
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
                                  _.tempLogin.value ? Get.back() : _.goToHome();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:0.15),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _.tempLogin.value
                                        ? Icons.arrow_back_rounded
                                        : Icons.home_rounded,
                                    color: colorGreen,
                                    size: 24,
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