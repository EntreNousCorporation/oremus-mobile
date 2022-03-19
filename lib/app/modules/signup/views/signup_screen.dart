import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/formatters/object_separator_input_formatter.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/signup/controller/signup_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/images/bg_login.jpg'),
        fit: BoxFit.cover,
      )),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: KeyboardDismisser(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: true,
                body: Center(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: SafeArea(
                      child: GetX<SignupController>(
                        initState: (_) {},
                        builder: (_) {
                          return WillPopScope(
                            onWillPop: () async => _.unlockBackButton.value,
                            child: AbsorbPointer(
                              absorbing: _.lockScreen.value,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    bottom: 20, left: 32, right: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //Separators.maximumVertical(),
                                    GestureDetector(
                                      onTap: () => Get.back(),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.arrow_back,
                                            color: colorWhite,
                                            size: 35,
                                          ),
                                          Separators.normalHorizontal(),
                                          Text(
                                            "S'inscrire",
                                            style: TextStyles.montserratBold(
                                                textSize: TextSizes.twenty_four,
                                                textColor: colorWhite),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: colorWhite,
                                      ),
                                      child: Form(
                                        key: _.formSignupKey,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 32,
                                              right: 32,
                                              top: 32,
                                              bottom: 32),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Rejoignez-nous",
                                                style:
                                                    TextStyles.montserratBold(
                                                        textSize: TextSizes
                                                            .twenty_four,
                                                        textColor: colorGreen),
                                              ),
                                              Separators.maximumVertical(),
                                              SizedBox(
                                                height: 45,
                                                child: MyTextField(
                                                  controller:
                                                      _.lastnameController,
                                                  hintText: '',
                                                  labelText: 'Nom',
                                                  prefixIcon:
                                                      "assets/images/icon_user.svg",
                                                  prefixIconColor: colorGrey1,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  maskInputs: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(AppConstants
                                                            .INPUT_NAME_REGEX)),
                                                  ],
                                                  onChanged: (value) {
                                                    _.checkForm();
                                                  },
                                                ),
                                              ),
                                              Separators.normalVertical(),
                                              SizedBox(
                                                height: 45,
                                                child: MyTextField(
                                                  controller:
                                                      _.firstnameController,
                                                  hintText: '',
                                                  labelText: 'Prénom(s)',
                                                  prefixIcon:
                                                      "assets/images/icon_user.svg",
                                                  //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                                  prefixIconColor: colorGrey1,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  maskInputs: [
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(AppConstants
                                                            .INPUT_NAME_REGEX)),
                                                  ],
                                                  onChanged: (value) {
                                                    _.checkForm();
                                                  },
                                                ),
                                              ),
                                              Separators.normalVertical(),
                                              SizedBox(
                                                height: 45,
                                                child: MyTextField(
                                                  controller: _.phoneController,
                                                  hintText: '',
                                                  labelText: 'Téléphone',
                                                  prefixIcon:
                                                      "assets/images/icon_phone.svg",
                                                  //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                                  prefixIconColor: colorGrey1,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maskInputs: [
                                                    ObjectSeparatorInputFormatter(
                                                        groupBy: 2),
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(AppConstants
                                                            .INPUT_NUM_REGEX)),
                                                  ],
                                                  onChanged: (value) {
                                                    _.checkForm();
                                                  },
                                                ),
                                              ),
                                              Separators.normalVertical(),
                                              SizedBox(
                                                height: 45,
                                                child: MyTextField(
                                                  controller:
                                                      _.passwordController,
                                                  hintText: '',
                                                  labelText: 'Mot de passe',
                                                  isPassword: true,
                                                  prefixIcon:
                                                      "assets/images/icon_password_profil.svg",
                                                  prefixIconColor: colorGrey1,
                                                  onChanged: (value) {
                                                    _.checkForm();
                                                  },
                                                ),
                                              ),
                                              Separators.normalVertical(),
                                              SizedBox(
                                                height: 45,
                                                child: MyTextField(
                                                  controller:
                                                      _.confPasswordController,
                                                  hintText: '',
                                                  labelText:
                                                      'Confirmer le mot de passe',
                                                  isPassword: true,
                                                  prefixIcon:
                                                      "assets/images/icon_password_profil.svg",
                                                  prefixIconColor: colorGrey1,
                                                  onChanged: (value) {
                                                    _.checkForm();
                                                  },
                                                ),
                                              ),
                                              Separators.normalVertical(),
                                              SizedBox(
                                                width: Get.width / 3.5,
                                                height: 40,
                                                child: CustomButton(
                                                  paddingVertical: 5,
                                                  icon:
                                                      'assets/images/icon_arrow_right.svg',
                                                  bgcolor: _.isValidForm.isTrue
                                                      ? colorGreen
                                                      : colorGreen
                                                          .withOpacity(0.5),
                                                  borderColor:
                                                      _.isValidForm.isTrue
                                                          ? colorGreen
                                                          : colorGreen
                                                              .withOpacity(0),
                                                  actionColor: colorGreen
                                                      .withOpacity(0.5),
                                                  enabled: _.isValidForm.value,
                                                  action: () {
                                                    _.signupUser();
                                                  },
                                                ),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child:
                                                    Separators.normalVertical(),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Text(
                                                  'Connectez-vous via',
                                                  style: TextStyles
                                                      .montserratSemiBold(
                                                          textSize:
                                                              TextSizes.sixteen,
                                                          textColor:
                                                              colorGrey1),
                                                ),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child:
                                                    Separators.normalVertical(),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 12.0),
                                                      child: SvgPicture.asset(
                                                        'assets/images/google_logo.svg',
                                                        height: 35,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0),
                                                      child: SvgPicture.asset(
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
      ),
    );
  }
}
