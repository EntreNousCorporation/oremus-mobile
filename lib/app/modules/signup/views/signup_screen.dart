import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/formatters/object_separator_input_formatter.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/signup/controller/signup_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.imagesBgLogin),
            fit: BoxFit.cover,
          )
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: GetX<SignupController>(
          builder: (_) {
            return FadeIn(
              preferences: const AnimationPreferences(
                duration: Duration(milliseconds: 800),
                offset: Duration(milliseconds: 300),
              ),
              child: KeyboardDismisser(
                child: Scaffold(
                  backgroundColor: Colors.black.withValues(alpha:0.3),
                  resizeToAvoidBottomInset: true,
                  body: SafeArea(
                    child: PopScope(
                      canPop: _.unlockBackButton.value,
                      child: AbsorbPointer(
                        absorbing: _.lockScreen.value,
                        child: Stack(
                          children: [
                            // Main Content
                            Center(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 80, // Space for the title
                                      bottom: 20,
                                      left: 24,
                                      right: 24
                                  ),
                                  child: SlideInUp(
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
                                        key: _.formSignupKey,
                                        child: Padding(
                                          padding: const EdgeInsets.all(28),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // Welcome Header with icon
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: colorGreen.withValues(alpha:0.15),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: colorGreen.withValues(alpha:0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.person_add_rounded,
                                                      color: colorGreen,
                                                      size: 28,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Rejoignez-nous",
                                                        style: TextStyles.montserratBold(
                                                          textSize: TextSizes.twenty_four,
                                                          textColor: colorGreen,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Créez votre compte",
                                                        style: TextStyles.montserratRegular(
                                                          textSize: TextSizes.fourteen,
                                                          textColor: Colors.grey[600]!,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 30),

                                              // Personal Info Section
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                  color: colorGreen.withValues(alpha:0.05),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: colorGreen.withValues(alpha:0.1),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8, bottom: 10),
                                                      child: Text(
                                                        "Informations personnelles",
                                                        style: TextStyles.montserratSemiBold(
                                                          textSize: TextSizes.fourteen,
                                                          textColor: colorGreen,
                                                        ),
                                                      ),
                                                    ),

                                                    // Lastname Field
                                                    MyTextField(
                                                      focusNode: _.lastnameFocusNode,
                                                      controller: _.lastnameController,
                                                      hintText: 'Votre nom',
                                                      labelText: 'Nom',
                                                      prefixIcon: "assets/images/icon_user.svg",
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.white,
                                                      //borderRadius: 16,
                                                      textCapitalization: TextCapitalization.words,
                                                      keyboardType: TextInputType.text,
                                                      maskInputs: [
                                                        FilteringTextInputFormatter.allow(
                                                            RegExp(AppConstants.INPUT_NAME_REGEX)
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.lastnameErrorMessage.value,
                                                    ),

                                                    const SizedBox(height: 15),

                                                    // Firstname Field
                                                    MyTextField(
                                                      focusNode: _.firstnameFocusNode,
                                                      controller: _.firstnameController,
                                                      hintText: 'Votre prénom',
                                                      labelText: 'Prénom(s)',
                                                      prefixIcon: "assets/images/icon_user.svg",
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.white,
                                                      //borderRadius: 16,
                                                      keyboardType: TextInputType.text,
                                                      textCapitalization: TextCapitalization.words,
                                                      maskInputs: [
                                                        FilteringTextInputFormatter.allow(
                                                            RegExp(AppConstants.INPUT_NAME_REGEX)
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.firstnameErrorMessage.value,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // Contact Info Section
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                  color: colorGreen.withValues(alpha:0.05),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: colorGreen.withValues(alpha:0.1),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8, bottom: 10),
                                                      child: Text(
                                                        "Coordonnées",
                                                        style: TextStyles.montserratSemiBold(
                                                          textSize: TextSizes.fourteen,
                                                          textColor: colorGreen,
                                                        ),
                                                      ),
                                                    ),

                                                    // Phone Field
                                                    MyTextField(
                                                      focusNode: _.phoneFocusNode,
                                                      controller: _.phoneController,
                                                      hintText: 'Votre numéro de téléphone',
                                                      labelText: 'Téléphone',
                                                      prefixIcon: Assets.imagesIconPhone,
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.white,
                                                      //borderRadius: 16,
                                                      keyboardType: TextInputType.phone,
                                                      maxLength: 14,
                                                      maskInputs: [
                                                        ObjectSeparatorInputFormatter(groupBy: 2),
                                                        FilteringTextInputFormatter.deny(RegExp(r'^00')),
                                                        FilteringTextInputFormatter.allow(
                                                            RegExp(AppConstants.INPUT_NUM_REGEX)
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.phoneErrorMessage.value,
                                                    ),

                                                    const SizedBox(height: 15),

                                                    // Email Field
                                                    MyTextField(
                                                      focusNode: _.emailFocusNode,
                                                      controller: _.emailController,
                                                      hintText: 'Votre adresse email',
                                                      labelText: 'E-mail',
                                                      prefixIcon: Assets.imagesIconEnveloppe,
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.white,
                                                      //borderRadius: 16,
                                                      keyboardType: TextInputType.emailAddress,
                                                      textCapitalization: TextCapitalization.none,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.emailErrorMessage.value,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              // Security Info Section
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                  color: colorGreen.withValues(alpha:0.05),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: colorGreen.withValues(alpha:0.1),
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

                                                    // Password Field
                                                    MyTextField(
                                                      focusNode: _.passwordFocusNode,
                                                      controller: _.passwordController,
                                                      hintText: 'Votre mot de passe',
                                                      labelText: 'Mot de passe',
                                                      isPassword: true,
                                                      prefixIcon: Assets.imagesIconPasswordProfil,
                                                      prefixIconColor: colorGreen,
                                                      //textFieldColor: Colors.white,
                                                      //borderRadius: 16,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _.passwordErrorMessage.value,
                                                    ),

                                                    const SizedBox(height: 15),

                                                    // Confirm Password Field
                                                    MyTextField(
                                                      focusNode: _.confPasswordFocusNode,
                                                      controller: _.confPasswordController,
                                                      hintText: 'Confirmez votre mot de passe',
                                                      labelText: 'Confirmer le mot de passe',
                                                      isPassword: true,
                                                      prefixIcon: Assets.imagesIconPasswordProfil,
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

                                              // Signup Button
                                              Hero(
                                                tag: 'signupButton',
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(18),
                                                    gradient: LinearGradient(
                                                      colors: _.isValidForm.isTrue
                                                          ? [
                                                        colorGreen.withValues(alpha:0.9),
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
                                                        color: colorGreen.withValues(alpha: 0.3),
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
                                                      _.signupUser();
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
                                                          "S'inscrire",
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
                                                          Assets.imagesIconArrowRight,
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
                                              ),

                                              const SizedBox(height: 20),

                                              // Already have account section
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Vous avez déjà un compte ?",
                                                    style: TextStyles.montserratRegular(
                                                      textSize: TextSizes.fourteen,
                                                      textColor: Colors.grey[600]!,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Get.back();
                                                    },
                                                    child: Text(
                                                      "Se connecter",
                                                      style: TextStyles.montserratSemiBold(
                                                        textSize: TextSizes.fourteen,
                                                        textColor: colorPurpleLight,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Back Button with animation
                            Positioned(
                              top: 20,
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
                              top: 20,
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
                                      "S'inscrire",
                                      style: TextStyles.montserratBold(
                                        textSize: TextSizes.twenty_four,
                                        textColor: colorWhite,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
