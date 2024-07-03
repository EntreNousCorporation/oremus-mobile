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
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.imagesBgLogin),
              fit: BoxFit.cover,
            )),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Stack(
            children: [
              FadeIn(
                child: KeyboardDismisser(
                  child: Scaffold(
                      backgroundColor: Colors.transparent,
                      resizeToAvoidBottomInset: false,
                      body: Center(
                        child: SingleChildScrollView(
                          reverse: false,
                          child: SafeArea(
                            child: GetX<SigninController>(
                              builder: (_) {
                                return WillPopScope(
                                  onWillPop: () async => _.unlockBackButton.value,
                                  child: AbsorbPointer(
                                    absorbing: _.lockScreen.value,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 20, left: 32, right: 32,),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Text(
                                            "S'identifier",
                                            style: TextStyles.montserratBold(
                                                textSize: TextSizes.twenty_four,
                                                textColor: colorWhite),
                                          ),
                                          Separators.normalVertical(),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(12),
                                              color: colorWhite,
                                            ),
                                            child: Form(
                                              key: _.formSigninKey,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 32,
                                                    right: 32,
                                                    top: 32,
                                                    bottom: 32),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Bienvenue",
                                                      style: TextStyles
                                                          .montserratBold(
                                                          textSize: TextSizes
                                                              .twenty_four,
                                                          textColor: colorGreen),
                                                    ),
                                                    Separators
                                                        .maximumVertical(),
                                                    MyTextField(
                                                      focusNode: _
                                                          .emailFocusNode,
                                                      controller: _
                                                          .emailController,
                                                      hintText: '',
                                                      labelText: 'E-mail',
                                                      prefixIcon: "assets/images/icon_enveloppe.svg",
                                                      //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                                      prefixIconColor: colorGrey1,
                                                      keyboardType: TextInputType
                                                          .emailAddress,
                                                      textCapitalization: TextCapitalization
                                                          .none,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _
                                                          .emailErrorMessage
                                                          .value,
                                                    ),
                                                    Separators.normalVertical(),
                                                    MyTextField(
                                                      focusNode: _
                                                          .passwordFocusNode,
                                                      controller: _
                                                          .passwordController,
                                                      hintText: '',
                                                      labelText: 'Mot de passe',
                                                      isPassword: true,
                                                      prefixIcon: 'assets/images/icon_password_profil.svg',
                                                      prefixIconColor: colorGrey1,
                                                      textCapitalization: TextCapitalization
                                                          .none,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _
                                                          .passwordErrorMessage
                                                          .value,
                                                    ),
                                                    //Separators.normalVertical(),
                                                    MaterialButton(
                                                      elevation: 0,
                                                      padding: const EdgeInsets
                                                          .only(right: 0),
                                                      onPressed: () {
                                                        _.goToForgotPassword();
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            'Mot de passe oublié ?',
                                                            style:
                                                            TextStyles
                                                                .montserratSemiBold(
                                                                textSize:
                                                                TextSizes
                                                                    .sixteen,
                                                                textColor:
                                                                colorPurpleLight),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Separators.normalVertical(),
                                                    //Separators.maximumVertical(),
                                                    SizedBox(
                                                      width: Get.width / 3.5,
                                                      height: 40,
                                                      child: CustomButton(
                                                        paddingVertical: 5,
                                                        icon: 'assets/images/icon_arrow_right.svg',
                                                        bgcolor: _.isValidForm
                                                            .isTrue
                                                            ? colorGreen
                                                            : colorGrey1
                                                            .withOpacity(0.5),
                                                        borderColor: _
                                                            .isValidForm.isTrue
                                                            ? colorGreen
                                                            : colorGreen
                                                            .withOpacity(0),
                                                        actionColor: colorGreen
                                                            .withOpacity(0.5),
                                                        enabled: _.isValidForm.value,
                                                        action: () {
                                                          _.connectUser();
                                                        },
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: false,
                                                      child: Separators
                                                          .normalVertical(),
                                                    ),
                                                    Visibility(
                                                      visible: false,
                                                      child: Text(
                                                        'Connectez-vous via',
                                                        style: TextStyles
                                                            .montserratSemiBold(
                                                            textSize: TextSizes
                                                                .sixteen,
                                                            textColor: colorGrey1),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: false,
                                                      child: Separators
                                                          .normalVertical(),
                                                    ),
                                                    Visibility(
                                                      visible: false,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                right: 12.0),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/images/google_logo.svg',
                                                              height: 35,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: 12.0),
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/images/facebook_logo.svg',
                                                              height: 35,
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
                                          Separators.maximumVertical(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              SizedBox(
                                                width: Get.width / 2,
                                                child: CustomButton(
                                                  borderRadius: 10,
                                                  text: "S'inscrire",
                                                  bgcolor: colorGreen,
                                                  borderColor: colorGreen,
                                                  actionColor: colorGreen
                                                      .withOpacity(0.5),
                                                  action: () {
                                                    _.goToSignup();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )),
                ),
              ),
              Positioned(
                top: Get.height * 0.06,
                child: GetBuilder<SigninController>(builder: (logic) {
                  return Visibility(
                    visible: logic.tempLogin.value == false,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            logic.goToHome();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(left: 24),
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0)),
                            ),
                            child: const Icon(
                                Icons.home_filled, color: colorGreen),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              Positioned(
                top: Get.height * 0.06,
                child: GetBuilder<SigninController>(builder: (logic) {
                  return Visibility(
                    visible: logic.tempLogin.value == true,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(left: 24),
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0)),
                            ),
                            child: const Icon(
                                Icons.arrow_back_rounded, color: colorGreen),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
